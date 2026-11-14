#import "WQAIResources.h"
#import "WQAccess.h"
#import <dirent.h>
#import <fcntl.h>
#import <unistd.h>
#import <errno.h>
#import <dlfcn.h>
#import <objc/runtime.h>

@protocol WQAIMetadataQuery <NSObject>
- (instancetype)initWithType:(NSString *)type;
- (long long)queryMetaDataSync;
- (NSArray *)results;
@end

static BOOL WQAIMethodMatches(Class cls, SEL selector, NSUInteger count, const char *returnType, BOOL objectArgument)
{
    Method method = class_getInstanceMethod(cls, selector);
    if (!method) return NO;
    NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)];
    if (sig.numberOfArguments != count || strcmp(sig.methodReturnType, returnType)) return NO;
    return !objectArgument || !strcmp([sig getArgumentTypeAtIndex:2], @encode(id));
}

NSDictionary *WQAIQueryCatalogClass(Class queryClass, NSString *assetType)
{
    NSMutableDictionary *result = [@{@"type": assetType} mutableCopy];
    if (!queryClass ||
        !WQAIMethodMatches(queryClass, @selector(initWithType:), 3, @encode(id), YES) ||
        !WQAIMethodMatches(queryClass, @selector(queryMetaDataSync), 2, @encode(long long), NO) ||
        !WQAIMethodMatches(queryClass, @selector(results), 2, @encode(id), NO)) {
        result[@"status"] = @"unsupported";
        return result;
    }
    @try {
        id<WQAIMetadataQuery> query = [(id<WQAIMetadataQuery>)[queryClass alloc] initWithType:assetType];
        if (!query) { result[@"status"] = @"unavailable"; return result; }
        long long code = [query queryMetaDataSync];
        result[@"code"] = @(code);
        // Keep the raw private API code: mappings can change across OS builds.
        result[@"status"] = @"returned";
        if (code == 0) {
            id records = [query results];
            if ([records isKindOfClass:NSArray.class]) result[@"catalogCount"] = @([records count]);
        }
    } @catch (NSException *__unused exception) {
        result[@"status"] = @"exception";
    }
    return result;
}

void WQAIQueryCatalog(void (^completion)(NSArray<NSDictionary *> *results))
{
    static dispatch_semaphore_t gate;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ gate = dispatch_semaphore_create(1); });
    if (dispatch_semaphore_wait(gate, DISPATCH_TIME_NOW) != 0) {
        dispatch_async(dispatch_get_main_queue(), ^{ completion(@[@{@"status": @"busy"}]); });
        return;
    }
    // Only the main queue touches delivered; late results cannot replace timeout.
    __block BOOL delivered = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 12 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (!delivered) { delivered = YES; completion(@[@{@"status": @"timeout"}]); }
    });
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        @autoreleasepool {
            // Keep the framework loaded while any ObjC objects may still exist.
            static void *framework;
            if (!framework) framework = dlopen("/System/Library/PrivateFrameworks/MobileAsset.framework/MobileAsset", RTLD_LAZY | RTLD_LOCAL);
            NSMutableArray *results = [NSMutableArray new];
            Class cls = framework ? NSClassFromString(@"MAAssetQuery") : Nil;
            for (NSString *type in @[@"com.apple.MobileAsset.UAF.FM.GenerativeModels", @"com.apple.MobileAsset.UAF.FM.Visual"])
                [results addObject:WQAIQueryCatalogClass(cls, type)];
            NSArray *snapshot = [results copy];
            dispatch_semaphore_signal(gate);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!delivered) { delivered = YES; completion(snapshot); }
            });
        }
    });
}

NSArray<NSString *> *WQAICandidatePaths(void)
{
    NSMutableArray *paths = [NSMutableArray new];
    // Asset names observed in iOS entitlement dumps. Locations may change;
    // each result must be checked on the device, including preinstalled assets.
    for (NSString *base in @[@"/private/var/MobileAsset/AssetsV2",
                             @"/private/var/MobileAsset/PreinstalledAssetsV2/InstallWithOs",
                             @"/System/Library/PreinstalledAssetsV2/RequiredByOs",
                             @"/System/Library/AssetsV2"]) {
        for (NSString *name in @[@"com_apple_MobileAsset_UAF_FM_GenerativeModels",
                                 @"com_apple_MobileAsset_UAF_FM_Visual"])
            [paths addObject:[base stringByAppendingPathComponent:name]];
    }
    return paths;
}

typedef struct {
    unsigned long long bytes;
    NSUInteger entries, limit, skipped;
    NSTimeInterval deadline;
    BOOL complete;
    int error;
} WQAIScan;

static void WQAIWalk(int fd, NSUInteger depth, WQAIScan *scan)
{
    if (depth > 32 || scan->entries >= scan->limit || NSProcessInfo.processInfo.systemUptime >= scan->deadline) {
        scan->complete = NO;
        close(fd);
        return;
    }
    DIR *dir = fdopendir(fd);
    if (!dir) { scan->complete = NO; scan->error = errno; close(fd); return; }
    for (;;) {
        if (scan->entries >= scan->limit || NSProcessInfo.processInfo.systemUptime >= scan->deadline) {
            scan->complete = NO;
            break;
        }
        errno = 0;
        struct dirent *entry = readdir(dir);
        if (!entry) {
            if (errno) { scan->complete = NO; scan->error = errno; }
            break;
        }
        if (!strcmp(entry->d_name, ".") || !strcmp(entry->d_name, "..")) continue;
        scan->entries++;
        struct stat st;
        if (fstatat(dirfd(dir), entry->d_name, &st, AT_SYMLINK_NOFOLLOW) != 0) {
            scan->complete = NO; scan->error = errno; continue;
        }
        if (S_ISREG(st.st_mode)) {
            if (st.st_size > 0) scan->bytes += (unsigned long long)st.st_size;
        } else if (S_ISDIR(st.st_mode)) {
            int child = openat(dirfd(dir), entry->d_name, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC);
            if (child < 0) { scan->complete = NO; scan->error = errno; continue; }
            WQAIWalk(child, depth + 1, scan);
        } else {
            scan->skipped++;
            scan->complete = NO;
        }
    }
    closedir(dir);
}

NSDictionary *WQAIInspectPath(NSString *path, NSTimeInterval seconds, NSUInteger entryLimit)
{
    NSMutableDictionary *result = [@{@"path": path, @"complete": @NO} mutableCopy];
    // Reuse the existing access mechanism, but perform no target writes or
    // create/delete probes. Failure means unknown size, never zero bytes.
    NSString *errorText = nil;
    if (!wq_list(path, &errorText)) {
        int code = errno;
        result[@"status"] = code == ENOENT ? @"notFound" : @"unavailable";
        result[@"errno"] = @(code);
        result[@"error"] = errorText ?: @"";
        return result;
    }
    int fd = open(path.fileSystemRepresentation, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC);
    if (fd < 0) {
        result[@"status"] = @"unavailable";
        result[@"errno"] = @(errno);
        return result;
    }
    struct stat st;
    if (fstat(fd, &st) == 0) {
        result[@"uid"] = @(st.st_uid);
        result[@"mode"] = @(st.st_mode & 07777);
    }
    // access() is a hint only; it does not check children, immutable flags,
    // sticky-bit ownership or whether a system service will download again.
    result[@"writeHint"] = @(access(path.fileSystemRepresentation, W_OK | X_OK) == 0);
    WQAIScan scan = {.limit = entryLimit,
        .deadline = NSProcessInfo.processInfo.systemUptime + MAX(0, seconds), .complete = YES};
    WQAIWalk(fd, 0, &scan);
    result[@"status"] = @"readable";
    result[@"complete"] = @(scan.complete);
    result[@"bytes"] = @(scan.bytes);
    result[@"entries"] = @(scan.entries);
    result[@"skipped"] = @(scan.skipped);
    result[@"errno"] = @(scan.error);
    return result;
}

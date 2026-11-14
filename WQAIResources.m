#import "WQAIResources.h"
#import "WQAccess.h"
#import <dirent.h>
#import <fcntl.h>
#import <unistd.h>
#import <errno.h>

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

#import <Foundation/Foundation.h>
#import "WQAIResources.h"
#import <dirent.h>
#import <errno.h>

// Access double: exercise real disposable files without issuing tokens.
NSArray<NSString *> *wq_list(NSString *path, NSString **errorText)
{
    (void)errorText;
    if ([path.lastPathComponent isEqualToString:@"denied"]) { errno = EACCES; return nil; }
    DIR *dir = opendir(path.fileSystemRepresentation);
    if (!dir) return nil;
    closedir(dir);
    return @[];
}

int main(void)
{
    @autoreleasepool {
        NSFileManager *fm = NSFileManager.defaultManager;
        NSString *root = [NSTemporaryDirectory() stringByAppendingPathComponent:NSUUID.UUID.UUIDString];
        NSString *nested = [root stringByAppendingPathComponent:@"nested"];
        NSCAssert([fm createDirectoryAtPath:nested withIntermediateDirectories:YES attributes:nil error:nil], @"fixture");
        NSData *data = [@"model fixture" dataUsingEncoding:NSUTF8StringEncoding];
        NSString *file = [nested stringByAppendingPathComponent:@"model.bin"];
        NSCAssert([data writeToFile:file atomically:YES], @"fixture data");
        NSDictionary *full = WQAIInspectPath(root, 5, 100);
        NSCAssert([full[@"complete"] boolValue], @"complete readable tree");
        NSCAssert([full[@"bytes"] unsignedLongLongValue] == data.length, @"logical size");
        NSCAssert([full[@"entries"] unsignedIntegerValue] == 2, @"nested entries");
        NSDictionary *missing = WQAIInspectPath([root stringByAppendingPathComponent:@"missing"], 5, 100);
        NSCAssert([missing[@"status"] isEqual:@"notFound"] && !missing[@"bytes"], @"missing is unknown size");
        NSDictionary *denied = WQAIInspectPath([root stringByAppendingPathComponent:@"denied"], 5, 100);
        NSCAssert([denied[@"status"] isEqual:@"unavailable"] && !denied[@"bytes"], @"denied is not zero or absent");
        NSCAssert(![WQAIInspectPath(root, 5, 0)[@"complete"] boolValue], @"entry limit");
        NSCAssert(![WQAIInspectPath(root, 0, 100)[@"complete"] boolValue], @"deadline");
        NSString *link = [root stringByAppendingPathComponent:@"loop"];
        NSCAssert([fm createSymbolicLinkAtPath:link withDestinationPath:root error:nil], @"symlink fixture");
        NSDictionary *partial = WQAIInspectPath(root, 5, 100);
        NSCAssert(![partial[@"complete"] boolValue] && [partial[@"skipped"] unsignedIntegerValue] == 1, @"link skipped");
        NSCAssert([partial[@"bytes"] unsignedLongLongValue] == data.length, @"no symlink double counting");
        NSCAssert([WQAIInspectPath(link, 5, 100)[@"status"] isEqual:@"unavailable"], @"root link refused");
        NSCAssert([[NSData dataWithContentsOfFile:file] isEqual:data], @"model untouched");
        NSCAssert(WQAICandidatePaths().count == 8, @"candidate coverage");
        [fm removeItemAtPath:root error:nil];
        puts("AI resource diagnostics: PASS");
    }
    return 0;
}

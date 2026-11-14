#import <Foundation/Foundation.h>

// Candidate locations, not a complete inventory or a deletion allowlist.
NSArray<NSString *> *WQAICandidatePaths(void);
// Metadata-only inspection. Size is a partial logical byte count when complete=NO.
// Writable directory hints never establish that its children can be deleted.
NSDictionary *WQAIInspectPath(NSString *path, NSTimeInterval seconds, NSUInteger entryLimit);

#import <Foundation/Foundation.h>

// Candidate locations, not a complete inventory or a deletion allowlist.
NSArray<NSString *> *WQAICandidatePaths(void);
// Metadata-only inspection. Size is a partial logical byte count when complete=NO.
// Writable directory hints never establish that its children can be deleted.
NSDictionary *WQAIInspectPath(NSString *path, NSTimeInterval seconds, NSUInteger entryLimit);

// Private-framework metadata probe, with runtime ABI checks. Never downloads
// or purges assets. Catalog counts are not installed-model counts.
NSDictionary *WQAIQueryCatalogClass(Class queryClass, NSString *assetType);
// Main-queue completion, once, within 12 seconds. A timed-out worker is not
// cancelled; further requests report busy until it actually returns.
void WQAIQueryCatalog(void (^completion)(NSArray<NSDictionary *> *results));

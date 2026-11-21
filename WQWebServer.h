//
//  WQWebServer.h
//  WQ Files
//
//  Wi-Fi sharing (issue #30): a small read-only web server for one folder.
//  A browser on the same Wi-Fi lists the folder, opens and downloads files and
//  downloads folders as ZIP, and (when switched on) uploads files. Password
//  protected (HTTP Basic, a new random password each start), bound to the
//  Wi-Fi address only; nothing is ever overwritten or deleted. The page
//  follows the app's design settings.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// A child of the shared folder that can't be listed the normal way (App Data
// and the other container roots are enumerated): its full path and the name
// to show.
@interface WQWebEntry : NSObject
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy, nullable) NSString *label;
@end

@interface WQWebServer : NSObject
- (instancetype)initWithRoot:(NSString *)root title:(NSString *)title
                 rootEntries:(nullable NSArray<WQWebEntry *> *)entries NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
// Binds to the Wi-Fi address (port 8080 or the next free one) and starts
// accepting. NO with a reason when there is no Wi-Fi or the port can't open.
- (BOOL)start:(NSString *_Nullable *_Nullable)errorText;
- (void)stop;
@property (nonatomic, readonly, getter=isRunning) BOOL running;
@property (nonatomic, readonly, nullable) NSString *address;   // http://192.168.1.20:8080/
@property (nonatomic, readonly) NSString *user;
@property (nonatomic, readonly) NSString *password;
// Uploads (PUT from the page's Upload button or drag and drop) into the
// shared folder and its subfolders. Off by default; never overwrites, a taken
// name gets " 2", " 3"… Settable while running.
@property (atomic) BOOL allowUploads;
// Called on the main queue for each served request ("GET /browse/…").
@property (nonatomic, copy, nullable) void (^requestHandler)(NSString *line);
@end

// Settings-style screen that runs the server while it is open: address, QR
// code, user and password, recent requests. Stops when closed or when WQ Files
// goes to the background.
void wq_present_wifi_sharing(UIViewController *host, NSString *root, NSString *title,
                             NSArray<WQWebEntry *> *_Nullable rootEntries, BOOL uploadable);

// Settings → Sharing Password: a fixed password (kept in the keychain)
// instead of a new random one each time; nil means random.
NSString *_Nullable wq_sharing_password(void);
BOOL wq_set_sharing_password(NSString *_Nullable password);
// Alert to set, change or remove it; done runs after a change.
void wq_edit_sharing_password(UIViewController *host, void (^_Nullable done)(void));

// Exposed for tests: maps a URL path below a route ("Documents/a%20b.txt")
// to path components, or nil when it would leave the folder.
NSArray<NSString *> *_Nullable WQWebPathComponents(NSString *encoded);
// A non-overwriting upload name: base + suffix (+ .ext), at most 255 bytes.
NSString *WQUploadCandidate(NSString *base, NSString *ext, NSString *suffix);
NSString *WQWebHTMLEscape(NSString *text);

NS_ASSUME_NONNULL_END

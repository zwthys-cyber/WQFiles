//
//  WQTheme.h
//  WQ Files
//
//  Settings → Theme: the colors of the new design. Built in: Default and
//  Custom Color (the color picker). More come from .wqtheme files, small JSON
//  documents anyone can write, import and share:
//
//    {
//      "name": "Midnight",                 1–40 characters (required)
//      "author": "you",                    optional, up to 60 characters
//      "dark":  { … },                     at least one of dark / light;
//      "light": { … }                      a missing one uses the other
//    }
//
//  Each appearance:
//      "background": "#0B1020" or ["#top", "#bottom"]   (required)
//      "glows":  up to four colors, usually with alpha ("#4D6BF29E")
//      "accent": buttons, tabs, links                   (optional)
//      "card":   tint over the cards' blur              (optional)
//      "plain":  the solid color for Plain Background   (optional)
//
//  Top level, optional:
//      "tiles": { "sky": ["#8AD9FF", "#2C94E8"], "mint": "#12B39A", … }
//               colors of the icon tiles (and Colored Cards) by name:
//               blue, sky, violet, indigo, mint, amber, orange, pink, gray,
//               or "all" for every tile not named. One color or two.
//
//  Colors are #RRGGBB or #RRGGBBAA. Unknown keys are ignored. Files over
//  64 KB, missing names or malformed colors are refused with the reason.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const WQThemeChangedNotification;
extern NSString *const WQThemeDefault;       // the built-in palette
extern NSString *const WQThemeCustomColor;   // tinted from the picked color

@interface WQThemeAppearance : NSObject
@property (nonatomic, strong) UIColor *baseTop, *baseBottom;
@property (nonatomic, copy) NSArray<UIColor *> *glows;
@property (nonatomic, strong, nullable) UIColor *accent, *card, *plain;
@end

@interface WQTheme : NSObject
@property (nonatomic, copy, readonly) NSString *identifier, *name;
@property (nonatomic, copy, readonly, nullable) NSString *author;
// Shipped with WQ Files (themes/ in the repository): can't be deleted.
@property (nonatomic, readonly) BOOL builtIn;
- (WQThemeAppearance *)appearanceDark:(BOOL)dark;
// Icon tile colors by tone name (and "all"), each [top, bottom].
@property (nonatomic, copy, readonly, nullable) NSDictionary<NSString *, NSArray<UIColor *> *> *tiles;
@end

// Parses and checks a theme file; nil with a reason when it isn't valid.
WQTheme *_Nullable wq_theme_parse(NSData *data, NSString *_Nullable *_Nullable errorText);
// Built-in and imported themes, sorted by name. An imported theme with the
// same name as a built-in one replaces it.
NSArray<WQTheme *> *wq_installed_themes(void);
// The active choice: WQThemeDefault, WQThemeCustomColor or an installed
// theme's identifier. The installed theme itself, or nil for the built-ins.
NSString *wq_active_theme_id(void);
WQTheme *_Nullable wq_active_theme(void);
void wq_set_active_theme_id(NSString *identifier);
// Copies a checked theme file in (replacing one with the same name) and
// makes it active. Returns the theme, or nil with a reason.
WQTheme *_Nullable wq_install_theme(NSURL *url, NSString *_Nullable *_Nullable errorText);
void wq_delete_theme(NSString *identifier);
// The installed file for sharing, or nil for the built-ins.
NSURL *_Nullable wq_theme_file(NSString *identifier);
// The colors in use now as a theme file, a starting point for your own.
NSData *wq_theme_export_current(NSString *name);
// Accent for tabs, navigation bars and the web page: the theme's, or the
// default blue. Follows light and dark mode.
UIColor *wq_theme_accent(void);
// Tint over the cards' blur, or nil for the default.
UIColor *_Nullable wq_theme_card(void);
// The active theme's [top, bottom] colors for an icon tile tone, or nil.
NSArray<UIColor *> *_Nullable wq_theme_tile_colors(NSString *tone);
// Settings → Theme → Colored Cards (on by default): start screen cards take
// on their icon's color.
BOOL wq_colored_cards(void);
void wq_set_colored_cards(BOOL on);
// Settings → Theme → Card Color: one color for every colored card instead of
// each icon's own; nil means the icon colors.
UIColor *_Nullable wq_card_color(void);
void wq_set_card_color(UIColor *_Nullable color);

// Settings → Theme screen.
UIViewController *wq_theme_settings_controller(void);
// A .wqtheme file opened in WQ Files (share sheet, Files app): installs it,
// makes it active and says so in an alert on host.
void wq_import_theme_url(UIViewController *_Nullable host, NSURL *url);

NS_ASSUME_NONNULL_END

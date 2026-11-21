> **Requires:** iOS 27, or iOS 26.0 – 26.7.2. Tested on iOS 27.0.1, 27.2.1, 27.3 (confirmed by a user) and 26.7.1; see [Tested devices](https://github.com/kolbicz/WQFiles#tested-devices).
> **Needs:** a sideloading tool that keeps the App Group entitlement; see [Signing](https://github.com/kolbicz/WQFiles#signing-the-app-group) in the README.

# Worse Query Files 0.9.14

## New

- **Show Folder Sizes** (Settings, off by default): folders show how much space they take, App Data included. They're measured in the background, folders on screen first, and kept for ten minutes; pull down to measure again. Sort by Size uses them.
- **Empty folders say so:** an empty folder shows "Empty Folder" instead of a blank screen, and a search that finds nothing says "No Results". With item counts or folder sizes on, empty subfolders read "Empty".
- **Colored Cards** (Settings → Theme, on by default): the start screen cards take on the color of their icon. **Card Color** gives every card one color you pick instead.
- **Themed tiles:** themes can now color the icon tiles on the start screen (`"tiles"` in a .wqtheme file; Midnight and Sunset do).

## Fixes

- **WQ Files is back in the Files app** (build 99): since 0.9.12, On My iPhone no longer listed WQ Files, so Backups and AppBackups couldn't be copied out. They can be again, e.g. to keep app backups somewhere safe before reinstalling WQ Files.
- **Wrong app names on iOS 26.5:** some apps were named after a file type they open, e.g. UC Browser as "셸 스크립트" (Shell Script) or Apple helpers with names in Telugu or Catalan. Names now come only from the app's own record.
- **Crash Logs "can't be fully measured":** WQ Files looked for crash logs in a folder that doesn't exist. It now looks where iOS keeps them. Where iOS doesn't let WQ Files read them (iOS 27.0.1), the section is left out instead of showing that note on every scan.
- **Faster measuring:** a folder that refused access was asked for access again and again during a scan. That's limited now. Files removed while a scan runs no longer make a size "incomplete", and the Log names what limited a measurement.

## Credit

New design: GpGp700. Sandbox technique: [worse_query](https://github.com/forcequitOS/worse_query) by Taj C (forcequit). Container enumeration: [KAMUI](https://github.com/murk-sus/kamui-escape) by murk-sus. Resumable scans: hhh2210. Translations: iosrxwy (Simplified Chinese), hfip (Arabic), hooray804 (Korean), Reinascape (Russian), romlayvn-93 (Vietnamese), buraakkcayir (Turkish review). Thanks to everyone who sent screenshots and Logs. GPL-3.0-or-later.

SHA-256 of WQFiles.ipa: `e38f44692ab79989660b39920b430864aa749e825ab08282b500675ca9846926`

> **Requires:** iOS 26.0 – 26.7.2, or iOS 27.0 up to 27.3 beta 1. **Not supported:** iOS 27.3 beta 2 and later, where Apple patched worse_query. Tested on iOS 27.0.1, 27.2.1, 27.3 beta 1 (confirmed by a user) and 26.7.1; see [Tested devices](https://github.com/kolbicz/WQFiles#tested-devices).
> **Needs:** a sideloading tool that keeps the App Group entitlement; see [Signing](https://github.com/kolbicz/WQFiles#signing-the-app-group) in the README.

# Worse Query Files 0.9.17

## Fixes

- **LiveContainer** ([#65](https://github.com/kolbicz/WQFiles/issues/65)): in a few LiveContainer setups every app folder was refused, because LiveContainer reported a different App Group folder than the one iOS hands out access for. WQ Files now prefers the App Group LiveContainer itself uses and always prepares the folder the access is really issued for (build 105). Ordinary installs and the many LiveContainer setups that already worked are unchanged.
- **Restoring an SQLite database** from Backups now also resets its `-wal`/`-shm` files. Before, SQLite could reopen the newer data after a "successful" restore. The replaced files are kept in Backups.
- **SQLite editor:** saving a field without changing it no longer turns NULL into empty text, and decimal numbers are shown with full precision.
- **Plist editor:** an XML plist is no longer saved with rounded dates (XML stores dates to the second; WQ Files now says so instead), and a file over 64 MB is refused instead of being read only in part.
- **App backups** are listed newest first in the file browser too, like in the restore picker.
- **Apps:** tapping an app while the search keyboard is up no longer shows a broken menu.
- **Clear Data** checks Allow Deleting again right before clearing.
- **Stopping a folder delete** now says how many files were already deleted and that their copies are in Backups.
- **Wi-Fi Sharing uploads** with very long names, or a name already used 999 times, no longer fail.
- **Access cache:** the automatic repair also fixes a broken lock file.
- **Simplified Chinese:** "Home" reads 首页 ([#68](https://github.com/kolbicz/WQFiles/pull/68)).

## Credit

New design: GpGp700. Sandbox technique: [worse_query](https://github.com/forcequitOS/worse_query) by Taj C (forcequit). Container enumeration: [KAMUI](https://github.com/murk-sus/kamui-escape) by murk-sus. Resumable scans: hhh2210. Translations: iosrxwy and FrogTool (Simplified Chinese), hfip (Arabic), hooray804 (Korean), Reinascape (Russian), romlayvn-93 (Vietnamese), buraakkcayir (Turkish review). Thanks to everyone who sent screenshots and Logs, especially ManuelKoegler and esterTion for the LiveContainer Logs. GPL-3.0-or-later.

SHA-256 of WQFiles.ipa: `4dbd55f88a2d796315f8ce63359b0a741b5e8a8107f1c1ec93291dd2129218f5`

> **Requires:** iOS 27, or iOS 26.0 – 26.7.2. Tested on iOS 27.0.1, 27.2.1, 27.3 (confirmed by a user) and 26.7.1; see [Tested devices](https://github.com/kolbicz/WQFiles#tested-devices).
> **Needs:** a sideloading tool that keeps the App Group entitlement; see [Signing](https://github.com/kolbicz/WQFiles#signing-the-app-group) in the README.

# Worse Query Files 0.9.12

## New

- **Wi-Fi Sharing** ([#30](https://github.com/kolbicz/WQFiles/issues/30)): a folder's **⋯ menu → Share on Wi-Fi…** opens a web page for that folder in any browser on the same Wi-Fi, so no Mac or AirDrop is needed. Browse, open and download files, and download folders as ZIP. With **Allow Uploads** you can add files by button or drag and drop; nothing is ever overwritten or deleted. It's password protected: user `wq`, with a new random password each time or a fixed one in **Settings → Sharing Password**, kept in the keychain. Sharing stops when you close the screen or leave WQ Files, and the page follows the app's design and theme.
- **Themes:** **Settings → Theme** with Default, Custom Color, and the built-in **Midnight** and **Sunset**. Import your own `.wqtheme` files: small JSON files with background, glows, accent and card colors for dark and light mode. Open one with WQ Files or use **Import Theme…**. **Export Current Colors…** gives you a starting point. The format is in the [README](https://github.com/kolbicz/WQFiles#themes). **Plain Background** works with every theme.
- **Recent:** a clock button on the start screen lists the folders and files you opened last, with the app they belong to.
- **Progress bars** while App Data, Extension Data and the Apps list are loading.

## Fixes

- **Frozen screen:** WQ Files could freeze while the Apps list showed its first icons, until iOS closed it.
- **Scan badge:** the tab bar shows a spinner while a scan runs and a clock while it waits. iPad now gets the same instead of a red badge.
- **Go to Path** suggests the path on the clipboard or the last one you opened, instead of `/private/var/`, which can't be opened.

## Credit

New design: GpGp700. Sandbox technique: [worse_query](https://github.com/forcequitOS/worse_query) by Taj C (forcequit). Container enumeration: [KAMUI](https://github.com/murk-sus/kamui-escape) by murk-sus. Resumable scans: hhh2210. Translations: iosrxwy (Simplified Chinese), hfip (Arabic), hooray804 (Korean), Reinascape (Russian), romlayvn-93 (Vietnamese), buraakkcayir (Turkish review). Thanks to deltaII for the file sharing idea, and to everyone who sent Logs and screenshots. GPL-3.0-or-later.

SHA-256 of WQFiles.ipa: `c77e034103aa1891a690fbbcd9237ece7623543b921eaa45db5878d4be065b70`

> **Requires:** iOS 26.0 – 26.7.2, or iOS 27.0 up to 27.3 beta 1. **Not supported:** iOS 27.3 beta 2 and later, where Apple patched worse_query. Tested on iOS 27.0.1, 27.2.1, 27.3 beta 1 (confirmed by a user) and 26.7.1; see [Tested devices](https://github.com/kolbicz/WQFiles#tested-devices).
> **Needs:** a sideloading tool that keeps the App Group entitlement; see [Signing](https://github.com/kolbicz/WQFiles#signing-the-app-group) in the README.

# Worse Query Files 0.9.15

> [!WARNING]
> **Apple patched worse_query in iOS 27.3 beta 2** (build 24C5049d). WQ Files can't open other apps' folders there or on any later build. Don't update to 27.3 beta 2 or later if you want to keep using it.

## New

- **iOS 27.3 beta 2 and later are recognized:** the startup check now says that Apple patched worse_query on these builds, instead of suggesting a reset that can't help. If some folders still open, it shows a warning.

## Fixes

- **Access cache repairs itself** ([#65](https://github.com/kolbicz/WQFiles/issues/65)): when another app sharing WQ Files' App Group (for example in LiveContainer) left its access cache broken, every folder was refused until you tapped Reset Access Cache. WQ Files now repairs it automatically and tries again. Nothing is deleted.
- **No more "the sandbox escape doesn't work on iOS 27.0.1":** if no folder opens on a supported iOS, the startup check names the likely cause (another app in the same App Group) and what to do, instead of blaming iOS.

## Credit

New design: GpGp700. Sandbox technique: [worse_query](https://github.com/forcequitOS/worse_query) by Taj C (forcequit). Container enumeration: [KAMUI](https://github.com/murk-sus/kamui-escape) by murk-sus. Resumable scans: hhh2210. Translations: iosrxwy (Simplified Chinese), hfip (Arabic), hooray804 (Korean), Reinascape (Russian), romlayvn-93 (Vietnamese), buraakkcayir (Turkish review). Thanks to everyone who sent screenshots and Logs. GPL-3.0-or-later.

SHA-256 of WQFiles.ipa: `d924596e7719038ac3fbdc8c1adea2e710ef4a6f3352ee1d56257f47f9cf02f1`

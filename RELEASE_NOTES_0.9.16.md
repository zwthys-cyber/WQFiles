> **Requires:** iOS 26.0 – 26.7.2, or iOS 27.0 up to 27.3 beta 1. **Not supported:** iOS 27.3 beta 2 and later, where Apple patched worse_query. Tested on iOS 27.0.1, 27.2.1, 27.3 beta 1 (confirmed by a user) and 26.7.1; see [Tested devices](https://github.com/kolbicz/WQFiles#tested-devices).
> **Needs:** a sideloading tool that keeps the App Group entitlement; see [Signing](https://github.com/kolbicz/WQFiles#signing-the-app-group) in the README.

# Worse Query Files 0.9.16

## New

- **Invert Selection** in the Cache Cleaner's Select menu. Select All and Invert are greyed out when no row can be cleaned, and Select None clears the selection everywhere, including rows the search hides.

## Fixes

- **LiveContainer** ([#65](https://github.com/kolbicz/WQFiles/issues/65)): inside LiveContainer every app folder was refused, and Reset Access Cache didn't help. LiveContainer gives WQ Files a stand-in App Group folder, while iOS hands out access for the real one. WQ Files now uses the real folder.
- **Cache Cleaner: Clean stayed grey after a scan** ([#67](https://github.com/kolbicz/WQFiles/issues/67)): since 0.9.11 a finished scan selected nothing. A scan that finishes while the Cache Cleaner is open now selects every row that can be cleaned again, as up to 0.9.10. Results shown again later, e.g. after a restart, still start with nothing selected.
- **Wi-Fi Sharing uploads:** nothing is saved anymore after you stop sharing, even if an upload was still running. An upload whose name already exists is saved as "name 2" again instead of failing.

## Credit

New design: GpGp700. Sandbox technique: [worse_query](https://github.com/forcequitOS/worse_query) by Taj C (forcequit). Container enumeration: [KAMUI](https://github.com/murk-sus/kamui-escape) by murk-sus. Resumable scans: hhh2210. Translations: iosrxwy (Simplified Chinese), hfip (Arabic), hooray804 (Korean), Reinascape (Russian), romlayvn-93 (Vietnamese), buraakkcayir (Turkish review). Thanks to everyone who sent screenshots and Logs. GPL-3.0-or-later.

SHA-256 of WQFiles.ipa: `66b0edea54a69c1d0021061b8f79efffe2cffb89574584ccc995727bd7dfa420`

> **Requires:** iOS 27, or iOS 26.0 – 26.7.2. Tested on iOS 27.0.1, 27.2.1, 27.3 (confirmed by a user) and 26.7.1; see [Tested devices](https://github.com/kolbicz/WQFiles#tested-devices).
> **Needs:** a sideloading tool that keeps the App Group entitlement; see [Signing](https://github.com/kolbicz/WQFiles#signing-the-app-group) in the README.

# Worse Query Files 0.9.13

## Fixes

- **Apps and Cache Cleaner are fast again:** since 0.9.11, measuring app data and caches ran at a low background priority (slower cores, throttled disk access). It also opened every folder's full path again for each subfolder. Scans now run at normal priority and measure many folders per step, so they're more than twice as fast. Pause, Resume and resuming after a restart work as before.

## Credit

New design: GpGp700. Sandbox technique: [worse_query](https://github.com/forcequitOS/worse_query) by Taj C (forcequit). Container enumeration: [KAMUI](https://github.com/murk-sus/kamui-escape) by murk-sus. Resumable scans: hhh2210. Translations: iosrxwy (Simplified Chinese), hfip (Arabic), hooray804 (Korean), Reinascape (Russian), romlayvn-93 (Vietnamese), buraakkcayir (Turkish review). Thanks to everyone who reported the slow scans. GPL-3.0-or-later.

SHA-256 of WQFiles.ipa: `8f72d4f70209743c8b2a05a62ffe4c279ead37a27b94cc8e9cb85cfdd1be0446`

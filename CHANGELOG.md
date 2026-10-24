# Change log: modifications made to the TV

Every change made to the TV is listed here with its original value and how to roll it back.

| Date | # | Change | Original value | New value | Rollback | Verified |
|---|---|---|---|---|---|---|
| 2026-10-24 | 3 | Voice Recognition Services (Settings → General → Terms & Privacy) | On | Off | Settings → General → Terms & Privacy → Voice Recognition Services → turn On and accept the terms | User confirmed the on-screen state. Note: all 10 voice-related processes still running right after the change (same PIDs); recheck after cold reboot |
| 2026-10-24 | 1 | Viewing Information Services (Terms & Privacy area; exact path TBD) | On | Off | Same menu → Viewing Information Services → turn On and agree | User reported done; TV online and sdb connected afterwards |
| 2026-10-24 | 2 | Interest-Based Advertisements (same screen as #1) | On | Off | Same menu → Interest-Based Advertisements → turn On and agree | User reported done |
| 2026-10-24 | 4 | Autorun Smart Hub (Settings → General → Smart Features) | On | Off | Settings → General → Smart Features → Autorun Smart Hub → On | User reported done |
| 2026-10-24 | 6 | Apple AirPlay (Settings → General → Apple AirPlay Settings) | On (inferred, not stated by user) | Off | Settings → General → Apple AirPlay Settings → AirPlay → On | User reported done |
| 2026-10-24 | — | Observation after cold reboot | Powered on to Samsung TV Plus | — | — | Cause confirmed by user: TV Plus is the TV input (no antenna) and was the last input. Leaving the TV on HDMI → powered on to HDMI after the next cold reboot. #4 behaves as intended |
| 2026-10-24 | — | Function check after all changes (user-reported) | — | — | — | Wi-Fi ✅, streaming playback ✅, Home button ✅, HDMI/CEC ✅, SmartThings ✅. Home-screen ads: no visible change (expected: #2 stops targeting only; removal needs #9 DNS blocking) |
| 2026-10-24 | — | Measurement after changes (14 min uptime, cold boot) | load 10.91/11.68/8.52, 732 MB free | load 10.67/10.44/7.21, 729 MB free | — | No measurable performance change. All ad/ACR/telemetry/voice/AirPlay services still running. See docs/03-measurements.md |
| 2026-10-24 | L1 | Installed custom launcher app **Shelf** (`ShelfHome0.Shelf`) over sdb | Not installed (22 apps) | Installed (23 apps) | `sdb shell 0 vd_appuninstall ShelfHome0.Shelf`, or Apps → Shelf → Delete. Removes only our own app | Install and launch confirmed by CLI. v1 on the TV: no wallpaper and quarter-screen layout (4K viewport, Chromium 76 CSS). Fixed and reinstalled. User confirmed: wallpaper shows, YouTube opens |
| 2026-10-24 | 11 | Autorun Last App (Settings → General → Smart Features) | Off | On | Same menu → Autorun Last App → Off | User: Shelf opened after power cycle; REST confirms Shelf running and visible |
| 2026-10-24 | A | Shelf pinned to the home bar (user) | Not pinned | Pinned first | Home bar → Shelf → Remove (only unpins) | User-reported |

## Non-TV changes (this computer)

| Date | Change | Rollback |
|---|---|---|
| 2026-10-24 | Installed `sdb` 4.2.36 to `~/.local/bin/sdb` | `rm ~/.local/bin/sdb` |
| 2026-10-24 | TV: Developer Mode **On**, Host PC IP `192.168.101.2` (done by user) | Apps → 12345 → Developer mode Off → cold reboot |
| 2026-10-24 | Installed Tizen Studio 6.1 CLI + TV extensions + Certificate Manager to `~/tizen-studio` | `~/tizen-studio/package-manager/package-manager-cli.bin uninstall --all`, then delete `~/tizen-studio` and `~/tizen-studio-data` |
| 2026-10-24 | Samsung certificate profile `ShelfTV` (certs in `~/SamsungCertificate/TVLauncher/`) | `tizen security-profiles remove -n ShelfTV` |
| 2026-10-24 | Created `~/.config/kwalletrc` (KWallet + Secret Service on) and a 'kdewallet' wallet, so Tizen can store the signing password | Delete `~/.config/kwalletrc`; delete the wallet in KWalletManager |
| 2026-10-24 | TV: Developer Mode turned **Off** by user after setup. Shelf stays installed; turn it back on (Apps → 12345) for sdb, reinstalls or discovery | Apps → 12345 → Developer mode On, Host PC IP `192.168.101.2` → cold reboot |

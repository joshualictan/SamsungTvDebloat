# 02 — Proposed changes (awaiting approval)

Every item is a **documented TV Settings toggle**, so it can be reversed by switching it back.
None of them can be done from the CLI. You make each change with the remote, after writing down
the original value in the table. Menu paths are for Tizen 6.0 (2021) and can differ slightly
between firmware versions.

Status values: `proposed` → `approved` / `rejected` / `deferred` → `applied` → `verified`.

| # | Change | Menu path | Expected benefit | Side effects | Original value | Status |
|---|---|---|---|---|---|---|
| 1 | Viewing Information Services → **Off** | Settings → General → Terms & Privacy → Privacy Choices | Stops ACR viewing-data collection (`contents-recognition-service`) | Fewer personalized recommendations. Playback unaffected | On | applied 2026-10-24, user reported done (exact menu location not yet recorded) |
| 2 | Interest-Based Advertisements → **Off** | Settings → General → Terms & Privacy → Privacy Choices | Ads are no longer profiled/targeted | Ads still appear, just untargeted | On | applied 2026-10-24, user reported done |
| 3 | Voice Recognition Services → **Off** | Settings → General → Terms & Privacy → Privacy Choices | No cloud voice processing | **Voice search/Bixby/Alexa stop working.** Do you use voice? | On | applied 2026-10-24, on-screen state confirmed by user |
| 4 | Autorun Smart Hub → **Off** | Settings → General → Smart Features | TV powers on to the last input, not the ad-filled home screen | You press Home to see the home screen | On | applied 2026-10-24, user reported done |
| 5 | Samsung TV Plus autorun → **Off** | Settings → General → Smart Features | TV Plus channel (ad-supported) won't start by itself | None | On | resolved without a setting change: with #4 off the TV powers on to the last input. TV Plus is the TV (tuner) input on this antenna-less TV, so it only appears if the TV was last on the TV input. Verified 2026-10-24: after a cold reboot from HDMI it powered on to HDMI |
| 6 | Apple AirPlay → **Off** | Settings → General → Apple AirPlay Settings | `airplay-service` goes idle | **Can't cast from iPhone/Mac.** Do you use AirPlay? | On (inferred: `airplay-service` was running; user did not state it) | applied 2026-10-24, user reported done |
| 7 | IoT / SmartThings auto-detect options → **Off** | Settings → General → External Device Manager / SmartThings | Less presence/scan activity | **SmartThings app control may stop.** Do you use SmartThings? | _record_ | rejected (user uses SmartThings) |
| 8 | App auto update → **Off** | Apps → ⚙ Settings → Auto Update | Stops background updates while watching | You update apps by hand; you miss fixes | _record_ | deferred (recommend leaving On) |
| 9 | DNS blocking of ad/ACR endpoints | Router or DNS blocker | Removes most home-screen ads and blocks ad/ACR traffic | Some home tiles go blank; a wrong block can break app logins | — | deferred: user has no DNS blocker yet. Set one up, collect a query log, then propose specific domains |

| 10 | Hide or remove Samsung TV Plus channels from the TV input | Settings → Broadcasting → channel list (to be checked) | TV input stops showing TV Plus | Unknown until the menu has been inspected | — | idea, not yet investigated |

| 11 | Autorun Last App → **On** | Settings → General → Smart Features | TV reopens Shelf at power-on if Shelf was the last app open | Reopens whichever app was last (e.g. YouTube) if you did not return to Shelf | Off | applied 2026-10-24, verified: Shelf reopened after power cycle (user + REST `running:true, visible:true`) |

## Intentionally left enabled

- **Software Update / Auto Update**: security fixes. Note: updates can reset some privacy toggles,
  so run `scripts/verify` steps after each update.
- **Smart Hub Terms & Conditions agreement**: declining it disables all apps.
- **HDMI-CEC (Anynet+)**, **Bluetooth**, **accessibility**, **network**: essential or in use.
- **SmartThings**: the user uses it (item 7 rejected).
- **Quick Start / Instant On**: keeps power-on fast.

## Approval

Reply with e.g. `1 approve, 2 approve, 3 reject, 4 defer …`. Once approved, apply one change
at a time: record the original value, change it, check the TV, then log it in
[../CHANGELOG.md](../CHANGELOG.md).

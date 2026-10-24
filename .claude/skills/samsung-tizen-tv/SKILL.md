---
name: samsung-tizen-tv
description: Inspect, debloat (reversibly) and build launcher apps for a Samsung Tizen smart TV over Developer Mode (sdb, REST 8001, remote WebSocket 8002). Use when working on the Samsung TV in this repo — connecting, discovery, privacy/ad settings, change approval, rollback, or the custom home-screen app.
---

# Samsung Tizen TV

Work on the user's Samsung Tizen TV safely and reversibly. Read `README.md`, `docs/01-discovery.md`
and `CHANGELOG.md` first: they hold the verified device facts and every change made so far.

## Verified platform facts (QA65Q60AAGXXP, Tizen 6.0)

- **Not Android.** Never suggest ADB, APKs, Android launchers or `pm` commands.
- Connect: `sdb connect <TV_IP>:26101` then `sdb devices`. Find the TV with
  `nmap -p 26101 --open <subnet>/24`, and confirm the model with `curl -s http://<TV_IP>:8001/api/v2/`
  (`modelName`, and `developerIP` must equal this PC's IP).
- Works:
  - `sdb shell 0 vd_applist`: installed apps (`app_title`, `app_tizen_id`, `is_removable`, `use_count`)
  - `sdb pull <path> <dest>`: reads `/etc/*-release`, `/proc/meminfo`, `/proc/loadavg`, `/proc/<pid>/cmdline`
  - `sdb capability`
  - REST `GET http://<TV_IP>:8001/api/v2/applications/<store_id>` (verified: status). POST launch and DELETE close exist on this API but haven't been tested here. Use the numeric `app_id` from vd_applist, not `app_tizen_id` (that returns 404)
- Does **not** work: root (`rootonoff_support:disabled`), general shell commands (`appcmd_support:disabled`),
  stopping/disabling system services, reading or writing settings, **screenshots**.
- Settings changes are done **by the user with the remote**. Your job is to give exact menu paths,
  get the original value recorded, and log the change.
- Custom UI = Tizen web app (`.wgt`), signed with a Samsung certificate (Tizen Studio Certificate
  Manager + Samsung account), installed over sdb. It can't replace the system home screen.
  The launcher **Shelf** (`launcher/`, ID `ShelfHome0.Shelf`) is installed and works. Build,
  sign and install steps are in `docs/04-launcher.md`.
- TV web-app quirks: 3840×2160 CSS viewport (scale a 1920×1080 stage), ~Chromium 76 (no `inset`,
  no flex `gap`). A desktop preview won't catch these; verify on the TV with a user photo.
- Signing passwords live only in the desktop keyring (Secret Service); `*.pwd` in profiles.xml
  are keyring labels. "Invalid password" = keyring not working, see docs/04-launcher.md.
- The settings toggles don't stop ad/ACR/telemetry services (measured: docs/03-measurements.md).

## Hard rules (from the user)

1. Never uninstall, delete or permanently remove apps.
2. No firmware changes, rooting, exploits or bypassing security.
3. Don't touch essential services, security, networking, updates, HDMI-CEC, accessibility or media
   dependencies without explaining consequences and getting explicit approval.
4. Don't block whole Samsung domains. Identify each endpoint's purpose from a DNS query log first.
5. Never act on a component just because its name looks unfamiliar or suspicious. Process purposes
   in `docs/01-discovery.md` are inferred from names only.
6. Ask before disabling anything the user might use (voice, AirPlay, SmartThings, apps).
7. Never fabricate screenshots or measurements. Mark anything unverifiable as **unavailable**.
8. Never commit pulled app data (it can contain login tokens) or private IDs (DUID, MAC, SSID).

## Workflow

1. Re-run discovery if the state might have changed: `scripts/discover.sh <TV_IP>`.
2. Propose changes in `docs/02-proposed-changes.md` (number, menu path, benefit, side effects,
   reversible?, rollback).
3. Wait for per-item approval (`approve` / `reject` / `defer`).
4. Apply **one** change: the user records the original value, makes the change, and confirms what
   they see (a photo if needed).
5. Log it in `CHANGELOG.md` with its rollback. Update the status in `02-proposed-changes.md`.
6. Check nothing broke: Wi-Fi, a streaming app, remote navigation, HDMI inputs, the Home button.
   If something broke, roll back first and confirm recovery before continuing.

## Current state

See the **Status** table in `README.md`. Update it whenever a phase moves forward.

# Samsung Tizen TV: safe debloat + minimal home screen

A careful, reversible approach to cutting ads, tracking and background clutter on a Samsung
Tizen smart TV, plus (planned) an Apple TV-inspired launcher app. Built and tested on a
**QA65Q60AAGXXP** (2021 Q60A, Tizen 6.0, firmware T-NKLAUABC-2310.0).

> **Not Android.** Tizen TVs have no ADB, no APKs and no replaceable launcher. Guides that say
> otherwise are for Android/Google TVs.

## Ground rules

- Never uninstall apps, flash firmware, root, or exploit the TV.
- Prefer the TV's own Settings toggles. Every change is recorded with its original value.
- Inspect → explain → approve → apply one change → verify → log.

## What's possible on a retail Tizen TV (verified)

| Can do | Can't do |
|---|---|
| List, install and launch apps over `sdb` (Developer Mode) | Root, normal shell, `ps`, or stopping system services |
| Read some system files (`/etc`, `/proc`) with `sdb pull` | Read or write TV settings from the CLI |
| Launch apps and read device info over the REST API (port 8001) | Take screenshots from the CLI |
| Toggle privacy, ad and autorun settings in the TV menus | Remove Samsung TV Plus, Gaming Hub, or home-screen ad tiles |
| Block ad/ACR domains with a DNS blocker | Replace the system home screen |
| Install your own signed launcher app (Shelf) | Stop ad/telemetry services (they keep running) |

## Quick start

1. Set up Developer Mode and `sdb`: [docs/00-setup.md](docs/00-setup.md)
2. Run read-only discovery: `scripts/discover.sh <TV_IP>`, which writes a snapshot to `baseline/<timestamp>/`
3. Read the findings: [docs/01-discovery.md](docs/01-discovery.md)
4. Approve or reject each proposed change: [docs/02-proposed-changes.md](docs/02-proposed-changes.md)
5. Apply approved changes one at a time and log them in [CHANGELOG.md](CHANGELOG.md)

## Layout

```
scripts/discover.sh        read-only inventory: device info, apps, processes, memory
docs/00-setup.md           Developer Mode, sdb install, connecting
docs/01-discovery.md       findings, access limits, process categories, baseline numbers
docs/02-proposed-changes.md  numbered change list with approval status
docs/03-measurements.md    before/after load, memory, processes
docs/04-launcher.md        Shelf launcher: build, sign, install, TV quirks
launcher/                  Shelf source (icons/wallpapers/apps.js are generated)
scripts/prepare-launcher.py  generate launcher data from the TV
scripts/add-cert-profile.sh  register Samsung signing certificate
CHANGELOG.md               every change made, original value, rollback
baseline/                  per-TV snapshots (git-ignored: device-specific)
.claude/skills/samsung-tizen-tv/SKILL.md   instructions for Claude Code to continue this work
```

## Status

| Phase | State |
|---|---|
| 1. Discovery | ✅ done |
| 2. Backup / recovery plan | ⏳ next: settings backup is a manual record (see limits) |
| 3. Debloat | ✅ 5 privacy/autorun settings applied and verified (privacy gain only; services keep running) |
| 4–5. Custom launcher app | ✅ **Shelf** installed and opens apps ([docs/04-launcher.md](docs/04-launcher.md)) |
| 6. Screenshot verification | ⚠️ no CLI capture; verified from user photos and reports |
| 7. Performance testing | ✅ before/after captured: no measurable change ([docs/03-measurements.md](docs/03-measurements.md)) |
| 8. Restore toolkit | planned (`backup.sh`, `restore.sh`, `verify.sh`) |

## Using with Claude Code

Open this folder in Claude Code. The project skill at
`.claude/skills/samsung-tizen-tv/SKILL.md` gives Claude the verified platform facts, the safety
rules and the workflow, so a new session can pick up where the last one stopped.

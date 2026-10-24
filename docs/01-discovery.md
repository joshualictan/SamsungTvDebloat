# 01 — Discovery results (Phase 1)

Captured 2026-10-24, about 5 minutes after a cold reboot. Raw data: `baseline/`.
**Nothing on the TV was changed during discovery.**

## Device

| Item | Value | Source |
|---|---|---|---|
| Model | QA65Q60AAGXXP ("Samsung Q60AA 65 TV") | REST `/api/v2/`, `sdb devices` |
| Model year / platform | 2021, codename `21_NIKEL_UHD` | REST `/api/v2/` |
| OS | Tizen 6.0.0 (Tizen6/TV), Linux 4.1.10, armv7 | `/etc/os-release`, `/proc/version` |
| Build | `T-NKLAUABC-REL-202607211855` | `/etc/tizen-release` |
| Firmware (UI) | T-NKLAUABC-2310.0 | Settings → Support → About This TV |
| CPU / RAM | 4 cores, 1.43 GB RAM (≈741 MB available at idle) | `/proc/cpuinfo`, `/proc/meminfo` |
| Region | PH (ISDB broadcast) | REST `countryCode` |
| Network | Wi-Fi | REST `networkType` |

**This is not Android.** There is no ADB, no APK support, no Android launcher mechanism.

## Access available

| Interface | Port | What it allows |
|---|---|---|---|
| `sdb` (Developer Mode) | 26101 | Install / uninstall / launch **user-signed** web apps; `sdb pull` read access to some files (`/etc`, `/proc`, app folders); a few vendor commands (`sdb shell 0 vd_applist`, `0 getduid`) |
| REST API | 8001 | Device info; app status/launch/close by **numeric store ID** (`/api/v2/applications/<store_id>`; the Tizen ID returns 404) |
| Remote-control WebSocket | 8002 (wss) | Send remote key presses; needs a one-time **Allow** prompt on the TV |

**Not available** (verified, `sdb capability`):

- `sdbd_rootperm:disabled`, `rootonoff_support:disabled`: no root (`sdb root on` → *Permission denied*)
- `appcmd_support:disabled`: ordinary shell commands (`ls`, `cat`, `ps`) return nothing
- No `sdb push` into system paths, no way to stop, disable or edit system services
- **No screenshot capture.** There's no screen-capture command available to a non-root sdb session.
  Visual verification has to be photos taken by the user.
- Settings (vconf/buxton) aren't readable or writable from the CLI. Settings changes and their
  backups have to be done by hand in the TV menus.

**Consequence:** system services (ads, ACR, telemetry) **cannot be disabled from the CLI**.
The only supported controls are the TV's own Settings toggles and network-level DNS blocking.

## Installed apps (from `sdb shell 0 vd_applist`): 22

All are marked `is_removable=1` and none are hidden. Per project rules **nothing will be uninstalled**.

| App | Tizen app ID | Store ID (REST API) | Uses |
|---|---|---|---|
| YouTube | `9Ur5IzDKqV.TizenYouTube` | `111299001912` | 4390 |
| Netflix | `org.tizen.netflix-app` | `3201907018807` | 1184 |
| Prime Video | `org.tizen.primevideo` | `3201910019365` | 187 |
| Browser | `org.tizen.browser` | `3202010022079` | 158 |
| Plex | `kIciSQlYEM.plex` | `3201512006963` | 139 |
| Stremio | `IkWsFHtOY9.Stremio` | `3202306031311` | 94 |
| Spotify | `rJeHak5zRg.Spotify` | `3201606009684` | 87 |
| HBO GO Asia | `tvhykAYCgz.hbogo` | `3202004020575` | 36 |
| Bay iptv | `FghL6ZXo27.Bayiptv` | `3202101022764` | 18 |
| Apple TV | `com.samsung.tv.aria-video` | `3201807016597` | 7 |
| Gallery | `com.samsung.tv.gallery` | `3201710015037` | 6 |
| IPStreamz IPTV | `XEBxBhmzjQ.IPStreamzTv` | `3202012022380` | 6 |
| M3U IPTV | `CYL8nSudXE.m3uIPTV` | `3202203026777` | 5 |
| Disney+ | `AwJZqXfE51.DisneyPlusHotstar` | `3202009021709` | 4 |
| TACKS | `M4UT1lus12.tacks` | `3201801015626` | 3 |
| IPTV Smart Pro | `beO68MHGJH.IPTVSmartPro` | `3202411037507` | 3 |
| Smart STB | `BqyAmbj01d.SmartSTB` | `3201606009761` | 2 |
| IPTV Smarters Pro | `rKpKZvmSog.IPTVSmartersPro` | `3202009021808` | 1 |
| e-Manual | `jPPp4KCHp4.emanual` | `20212100003` | 0 |
| Google Meet | `IewQEY143t.GoogleDuoWeb` | `3202008021439` | 0 |
| Security Center | `J9fZJDMi1v.SecurityCenter` | `3202009021877` | 0 |
| Weverse | `dUty1U3vVh.Weverse` | `3202012022420` | 0 |

Samsung TV Plus, Gaming Hub, the Smart Hub home screen and its ad tiles **are not in this list**.
They're system components and can't be managed as apps.

## Running system components (189 unique processes)

Full list: `baseline/process_summary.txt`. Below are the ones relevant to the project goals.
**Purposes are inferred from process names** and haven't been confirmed by Samsung documentation,
so nothing gets disabled based on a name alone. None of them can be stopped from the CLI anyway.
They're listed so each Settings toggle can be matched to what it should quiet down.

| Category | Processes (inferred) | Controlled by |
|---|---|---|---|
| Advertising | `adagent-service`, `targeted-ad-service` | Terms & Privacy → Interest-Based Ads; DNS blocking |
| Viewing data / ACR | `contents-recognition-service`, `media-analytics-service` | Terms & Privacy → Viewing Information Services |
| Recommendations / home tiles | `content-tiles-provider`, `csf-content-engine`, `homedatacontrol-service`, `utterance-recommender-core` | Smart Hub settings (limited); DNS blocking |
| Telemetry / logging | `kpi-logging`, `sp-kpi`, `canalysis-daemon`, `issue_report_agent`, `emergencyLogTransmitter`, `abnormal_user_behavior`, `devicetracker` | Privacy notice opt-outs; DNS blocking |
| Voice / Bixby / Alexa | `voice-app`, `voice-client`, `ondevice-voice`, `bixby-prov`, `bixbycapsuleviewer`, `org.tizen.multi-assistant-service`, `voice-interaction-framework`, `action-planner-service` | Voice Assistant settings, Voice Recognition consent |
| SmartThings / IoT / presence | `smartthings-client`, `smartthings-thing`, `com.samsung.tv.wifi-presence`, `ambient-ua-agent`, `context-aware-agent`, `context-aware-service` | SmartThings / IoT settings |
| Casting / mirroring | `airplay-service`, `dmr`, `allshare-svc`, `screen_sharing`, `wfd-manager`, `msf-server` | Apple AirPlay setting; Connection settings |
| Updates | `SWUAutoUpgrade`, `was_background_update` | Software Update → Auto Update; app auto update |
| HbbTV | `hbbtv_app`, `hbbtv_service` | Broadcasting settings, where available |
| **Essential (never touch)** | `systemd`, `deviced`, `connmand`, `wpa_supplicant`, `pulseaudio`, `media-server`, `hdmicec-service`, `security-manager`, `cynara`, `enlightenment`, `tv-viewer`, `source-service`, `bt-service`, `sdbd`, `webappservice` | — |

## Background activity observed

- Netflix was running in the background without being visible (`GET /api/v2/applications/3201907018807` returned `"running":true,"visible":false`).

## Baseline measurements

| Metric | Value | Note |
|---|---|---|---|
| Load average (1/5/15 min) | 11.52 / 10.85 / 5.36 | Taken 5 min after boot, so startup activity skews it. Re-measure after 30+ min idle |
| Memory available | 741 MB of 1432 MB | `/proc/meminfo` |
| Threads | 1711 | `/proc/loadavg` |
| App launch time | not measured yet | Plan: time REST launch → app ready, or a stopwatch |
| Home-screen latency | not measurable from CLI | Needs a manual stopwatch or video |
| Network activity | not measurable from CLI | Needs a router or DNS-blocker query log |

## Phase 4 feasibility (custom interface)

- Replacing Samsung's home screen: **not supported.** A third-party app can't become the launcher.
- **Feasible:** a Tizen web app (`.wgt`) with the Apple TV-inspired layout. You'd open it from Apps
  (or pin it to the home bar), it launches your streaming apps by app ID, and the remote's Home
  button always goes back to the Samsung home screen. Wallpapers can be bundled locally.
- Requirements: Tizen Studio CLI plus a **Samsung certificate**, made with Certificate Manager
  and a Samsung account, so the TV accepts the app.
- Starting at boot: not supported for user apps. The nearest option is the TV's own
  "Autorun Last App" setting.

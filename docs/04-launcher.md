# 04 — Shelf: Apple TV-inspired launcher (Phases 4–5)

A Tizen web app with an Apple TV-style look: rotating nature wallpaper, a large title for the
focused app, a dock of 6 favourites and a dimmer row with the other apps. It **doesn't replace**
Samsung's home screen, because Tizen doesn't allow that. You open it from Apps or pin it to the
home bar, and the remote's **Home** button always goes back to Samsung's home screen.

Verified on the TV (2026-10-24, from a user photo and report): it renders full screen with the
wallpaper, navigation works, and **OK on YouTube opens YouTube**.

## Files

| Path | What |
|---|---|
| `launcher/config.xml` | App manifest: ID `ShelfHome0.Shelf`, privileges `application.launch`, `tv.inputdevice` |
| `launcher/index.html`, `style.css`, `app.js` | The UI. Plain JS, no libraries |
| `launcher/icon.png` | Original icon (mountain silhouette), drawn in code |
| `launcher/apps.js` | **Generated**: dock, other apps, wallpaper list |
| `launcher/icons/`, `launcher/wallpapers/` | **Generated**: app icons pulled from the TV, and 13 nature photos |
| `scripts/prepare-launcher.py` | Generates the three items above from the TV |
| `scripts/add-cert-profile.sh` | Registers the Samsung certificate as a CLI signing profile |

## Build and install

```bash
sdb connect <TV_IP>:26101
python3 scripts/prepare-launcher.py            # or --dock "YouTube,Netflix,Plex"
T=~/tizen-studio/tools/ide/bin/tizen
B=$(mktemp -d) && cp -r launcher/. "$B"/
$T build-web -- "$B"
$T package -t wgt -s ShelfTV -- "$B/.buildResult"
$T install -n Shelf.wgt -s <TV_IP>:26101 -- "$B/.buildResult"
$T run -p ShelfHome0.Shelf -s <TV_IP>:26101
```

Preview on the PC (no TV needed): open `launcher/index.html` in a browser. Use the arrow keys and
Enter; app launches are simulated. `?row=1&col=3` sets the starting focus.

**Remove:** Apps → Shelf → Delete, or `sdb shell 0 vd_appuninstall ShelfHome0.Shelf`.
This removes only Shelf.

## One-time setup (PC)

1. Tizen Studio 6.1 CLI from `download.tizen.org/sdk/Installer/tizen-studio_6.1/`
   (`web-cli_Tizen_Studio_6.1_ubuntu-64.bin --accept-license ~/tizen-studio`).
2. `package-manager-cli.bin install --accept-license cert-add-on TV-SAMSUNG-Public-WebAppDevelopment TV-SAMSUNG-Extension-Tools`
3. **Certificate Manager on non-Ubuntu Linux:** `install Certificate-Manager` fails on Ubuntu-only
   (`libkf5…`) dependency checks. Download `certificate-manager-product_<ver>_ubuntu-64.zip` from
   the package index, check its SHA-256, and unzip its `data/` into `~/tizen-studio/`.
4. In Certificate Manager: **+ → Samsung → TV**, create the author certificate (**write the
   password down**), sign in with a Samsung account, and create the distributor certificate. The
   TV's DUID is filled in automatically when sdb is connected.
5. `scripts/add-cert-profile.sh ~/SamsungCertificate/<name>`

### Keyring

Tizen stores signing passwords **only** in the desktop keyring (Secret Service), through its own
bundled `tools/certificate-encryptor/secret-tool`. The `*.pwd` paths in `profiles.xml` are
**keyring labels, not files**. Plain-text passwords in `profiles.xml` aren't accepted.
Without a keyring, signing fails with `Invalid password`.

On KDE Plasma 6:
```bash
kwriteconfig6 --file kwalletrc --group Wallet --key Enabled true
kwriteconfig6 --file kwalletrc --group org.freedesktop.Secret --key apiEnabled true
kwalletd6 &   # then create the wallet when KDE asks: choose "Classic, blowfish", not GPG
```
Test: `echo -n x | secret-tool store --label=t app t && secret-tool clear app t`.

## TV quirks (Tizen 6.0, QA65Q60AAGXXP)

- Web apps get a **3840×2160 CSS px** viewport, despite `<meta viewport width=1920>`. Shelf
  lays out a fixed 1920×1080 stage and scales it with `transform: scale()` in `app.js`.
- The browser engine is about **Chromium 76**. Unsupported features include `inset` (elements
  end up with zero size) and flex `gap`. Use `top/right/bottom/left` and margins instead.
  A desktop preview won't show these bugs; only the TV does.
- Launch other apps with `tizen.application.launch(<app_tizen_id>)`, e.g. `9Ur5IzDKqV.TizenYouTube`.
- Some app titles carry suffixes or trailing spaces ("Spotify - Music and Podcasts", "Bay iptv ").

## Wallpapers

13 photos from picsum.photos (Unsplash photos, Unsplash License), bundled in the app so it makes no
network requests. They rotate every 45 s, and only while Shelf is visible.

## Not yet verified

- Back closes Shelf; Home still reaches Samsung's home screen
- Launching each of the other 21 apps (only YouTube has been confirmed)

#!/usr/bin/env python3
"""Generate launcher/apps.js and launcher/icons/ from the TV, and fetch wallpapers.

Runs on your computer. Reads the TV's app list and app icons over sdb (read-only),
picks each tile's background colour from its icon's edge, and downloads the bundled
nature wallpapers (Unsplash photos served by picsum.photos, Unsplash License).

Usage: scripts/prepare-launcher.py [--dock "YouTube,Netflix,..."]
Requires: sdb connected to the TV, Pillow.
"""
import argparse
import json
import re
import subprocess
import sys
import urllib.request
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
APP_DIR = ROOT / "launcher"
DEFAULT_DOCK = "YouTube,Netflix,Prime Video,Plex,Stremio,Spotify"
# picsum.photos ids, chosen for nature only (no people or cities).
WALLPAPERS = {
    29: "Mountains", 1015: "Fjord", 1018: "Highlands",
    10: "Forest", 28: "Forest stream", 1043: "Yosemite",
    13: "Coast", 1019: "Storm over the sea", 1050: "Sea stacks",
    15: "Waterfall", 1039: "Falls", 1016: "Canyon", 1051: "Alpine lake",
}


def sdb(*args):
    return subprocess.run(["sdb", *args], capture_output=True, text=True, check=True).stdout


def parse_applist(text):
    apps, cur = [], None
    for line in text.splitlines():
        m = re.match(r"-+(\w[\w()?:,]*)\s*=(.*?)-{5,}$", line.strip())
        if not m:
            continue
        key, val = m.groups()
        if key == "app_id":
            cur = {"storeId": val}
            apps.append(cur)
        elif cur is not None and key in ("app_title", "app_tizen_id", "use_count", "is_hidden"):
            cur[key] = val
    return [a for a in apps if a.get("is_hidden") == "0"]


def edge_colour(png):
    im = Image.open(png).convert("RGBA")
    w, h = im.size
    # Mid-edge points: corners are often shaded or rounded and give the wrong colour.
    px = [im.getpixel((x, y)) for x, y in ((2, h // 2), (w - 3, h // 2), (w // 2, 2), (w // 2, h - 3))]
    px = [p for p in px if p[3] > 200] or [(28, 28, 30, 255)]
    r, g, b = (sum(p[i] for p in px) // len(px) for i in range(3))
    return f"#{r:02x}{g:02x}{b:02x}"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dock", default=DEFAULT_DOCK)
    dock = [s.strip() for s in ap.parse_args().dock.split(",")]

    apps = parse_applist(sdb("shell", "0", "vd_applist"))
    if not apps:
        sys.exit("No apps returned. Is sdb connected? (sdb devices)")

    icons = APP_DIR / "icons"
    icons.mkdir(parents=True, exist_ok=True)
    out = []
    for a in apps:
        dest = icons / f"{a['storeId']}.png"
        src = f"/opt/share/webappservice/apps_icon/all/{a['storeId']}/304x304.png"
        subprocess.run(["sdb", "pull", src, str(dest)], capture_output=True)
        has_icon = dest.exists() and dest.stat().st_size > 0
        out.append({
            # "Spotify - Music and Podcasts" -> "Spotify"; some titles carry trailing spaces.
            "title": a["app_title"].split(" - ")[0].strip(),
            "tizenId": a["app_tizen_id"],
            "storeId": a["storeId"],
            "icon": f"icons/{dest.name}" if has_icon else None,
            "bg": edge_colour(dest) if has_icon else "#1c1c1e",
            "uses": int(a.get("use_count") or 0),
        })

    by_title = {a["title"]: a for a in out}
    missing = [t for t in dock if t not in by_title]
    if missing:
        sys.exit(f"Dock apps not installed: {missing}. Installed: {sorted(by_title)}")
    rest = sorted((a for a in out if a["title"] not in dock), key=lambda a: -a["uses"])

    walls = APP_DIR / "wallpapers"
    walls.mkdir(parents=True, exist_ok=True)
    wall_list = []
    for pid, label in WALLPAPERS.items():
        dest = walls / f"{pid}.jpg"
        if not dest.exists():
            req = urllib.request.Request(f"https://picsum.photos/id/{pid}/1920/1080",
                                         headers={"User-Agent": "prepare-launcher"})
            with urllib.request.urlopen(req, timeout=30) as r:
                dest.write_bytes(r.read())
        wall_list.append({"src": f"wallpapers/{dest.name}", "label": label})

    data = {"dock": [by_title[t] for t in dock], "apps": rest, "wallpapers": wall_list}
    # A .js file rather than JSON so index.html loads it with <script> (no fetch from file://).
    (APP_DIR / "apps.js").write_text("window.SHELF_DATA = " + json.dumps(data, indent=1) + ";\n")
    print(f"dock: {len(data['dock'])}, other apps: {len(rest)}, wallpapers: {len(wall_list)}")


if __name__ == "__main__":
    main()

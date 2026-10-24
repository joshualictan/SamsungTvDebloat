#!/usr/bin/env bash
# Read-only discovery of a Samsung Tizen TV in Developer Mode.
# Runs on your computer; talks to the TV via sdb (port 26101) and the
# local REST API (port 8001). Changes nothing on the TV.
#
# Usage: scripts/discover.sh [TV_IP] [OUT_DIR]
#   TV_IP    auto-detected by scanning the local /24 for port 26101 if omitted
#   OUT_DIR  defaults to baseline/<timestamp>
set -euo pipefail

TV_IP="${1:-}"
OUT="${2:-baseline/$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$OUT/procs"

command -v sdb >/dev/null || { echo "sdb not found (see README: Installing sdb)"; exit 1; }

if [[ -z "$TV_IP" ]]; then
  subnet=$(ip -4 route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}' | cut -d. -f1-3)
  echo "Scanning $subnet.0/24 for Tizen dev-mode port 26101..."
  for i in $(seq 1 254); do
    (timeout 1 bash -c "echo >/dev/tcp/$subnet.$i/26101" 2>/dev/null && echo "$subnet.$i") &
  done > "$OUT/.ip"
  wait
  TV_IP=$(head -1 "$OUT/.ip"); rm -f "$OUT/.ip"
  [[ -n "$TV_IP" ]] || { echo "No TV found. Is Developer Mode on and Host PC IP set?"; exit 1; }
fi
echo "TV: $TV_IP"

# Identify the device before trusting it. Private IDs are stripped.
curl -s -m 5 "http://$TV_IP:8001/api/v2/" | python3 -I -c '
import json,sys; d=json.load(sys.stdin)
for k in ("id","duid","wifiMac","udn","ssid"): d["device"].pop(k,None)
d.pop("id",None); json.dump(d,sys.stdout,indent=2)' > "$OUT/rest_api_v2.json"
echo "Model: $(python3 -I -c 'import json,sys;print(json.load(open(sys.argv[1]))["device"]["modelName"])' "$OUT/rest_api_v2.json")"

sdb connect "$TV_IP:26101" >/dev/null
sdb capability > "$OUT/sdb_capability.txt"
sdb shell 0 vd_applist > "$OUT/vd_applist.txt"

# Retail TVs block normal shell commands, but sdb pull can read these.
for f in /etc/os-release /etc/tizen-release /proc/version /proc/meminfo /proc/cpuinfo /proc/loadavg /proc/uptime; do
  sdb pull "$f" "$OUT/$(basename "$f")" >/dev/null 2>&1 || echo "could not read $f"
done

# Process list: no `ps`, so read /proc/<pid>/cmdline for every candidate pid.
echo "Collecting process list (takes a minute)..."
seq 1 "${PID_MAX:-6000}" | xargs -P 24 -I{} sh -c \
  'sdb pull /proc/{}/cmdline "$0/{}" >/dev/null 2>&1 && [ -s "$0/{}" ] || rm -f "$0/{}"' "$OUT/procs"
for f in "$OUT"/procs/*; do
  tr '\0' ' ' < "$f" | awk '{print $1}' | xargs basename
done | sort | uniq -c > "$OUT/process_summary.txt"
rm -rf "$OUT/procs"

echo "Saved to $OUT"

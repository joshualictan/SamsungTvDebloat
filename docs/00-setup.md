# 00 — Setup: Developer Mode + sdb

Everything here was done on a QA65Q60AAGXXP (2021 Q60A, Tizen 6.0) from a Linux PC.
No step changes TV firmware or system files.

## 1. Find your PC's LAN IP

```bash
ip -4 -o addr show scope global | awk '{print $2, $4}'
```

Use the address on the same network as the TV (e.g. `wlan0 192.168.101.2/24`), not VPN/VM
interfaces (tailscale, vmnet, etc.).

## 2. Turn on Developer Mode on the TV

1. Open **Apps** from the home screen.
2. Type **1 2 3 4 5** on the remote (on-screen number pad if the remote has no digits).
3. Switch **Developer mode** to **On**, enter the PC's IP as **Host PC IP**.
4. **Cold reboot:** hold the remote's power button until the Samsung logo appears.
   A normal off/on is not enough.
5. Reopen Apps. A "Developer Mode" banner confirms it.

To undo: same menu, switch it **Off**, cold reboot.

## 3. Install sdb (Smart Development Bridge)

Standalone binary from Tizen's official package server — no full Tizen Studio needed for discovery.

```bash
# Check for the newest version first:
#   https://download.tizen.org/sdk/tizenstudio/official/binary/  (look for sdb_<ver>_ubuntu-64.zip)
VER=4.2.36
mkdir -p /tmp/sdb-dl && cd /tmp/sdb-dl
curl -fLO "https://download.tizen.org/sdk/tizenstudio/official/binary/sdb_${VER}_ubuntu-64.zip"
unzip -o "sdb_${VER}_ubuntu-64.zip" -d x
install -m 755 x/data/tools/sdb ~/.local/bin/sdb   # ~/.local/bin must be on PATH
sdb version
```

Building and signing a custom app (Phase 4/5) needs the full Tizen Studio CLI + a Samsung
certificate; that is covered separately when we get there.

## 4. Find the TV and connect

If you don't know the TV's IP, scan for the dev-mode port:

```bash
nmap -p 26101,8001,8002 --open 192.168.101.0/24
```

Verify it is the right device before connecting — the TV's local REST API reports its model:

```bash
curl -s http://<TV_IP>:8001/api/v2/ | python3 -m json.tool | grep -E 'modelName|OS|developerMode|developerIP'
```

`developerIP` must equal your PC's IP and `developerMode` must be `"1"`.

```bash
sdb connect <TV_IP>:26101
sdb devices        # should list the model name, e.g. QA65Q60AAGXXP
```

## 5. Run discovery

```bash
scripts/discover.sh <TV_IP>
```

Read-only. Saves a timestamped snapshot under `baseline/`. See [01-discovery.md](01-discovery.md)
for what was found and what the access limits are.

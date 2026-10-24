# 03 — Before/after measurements (Phase 7)

Both snapshots were taken at **14.1 min uptime** after a cold boot, read from `/proc` over `sdb pull`.
Raw data: `baseline/pre-change-20261024-170026/`, `baseline/post-change-20261024/`.

| Metric | Before (#1–#4, #6 not applied) | After (#1–#4, #6 applied) | Difference |
|---|---|---|---|
| Load average 1 / 5 / 15 min | 10.91 / 11.68 / 8.52 | 10.67 / 10.44 / 7.21 | Within normal variation. No clear change |
| MemAvailable | 732 MB | 729 MB | None |
| Unique processes | 189 | 190 | None |

## Background services after the changes

Every watched service was **still running** after the cold reboot:
`adagent-service`, `targeted-ad-service`, `contents-recognition-service`, `media-analytics-service`,
`kpi-logging`, `sp-kpi`, `canalysis-daemon`, all 10 voice/Bixby processes, `airplay-service`,
`content-tiles-provider`, `netflix-app`.

## Conclusion

On this firmware the privacy toggles withdraw **consent** (they stop the TV sending or using that
data), but they **don't stop the services** and give **no measurable performance gain**. Turning
off AirPlay and voice recognition didn't stop their processes either. Whether data still leaves
the TV can only be checked at network level (DNS query log, proposal #9).

## Not measured

| Metric | Why |
|---|---|
| App launch time | No CLI timing hook. Needs a stopwatch or a video |
| Home-screen navigation latency | Not measurable from the CLI |
| Network activity | Needs a DNS blocker or router log (#9) |

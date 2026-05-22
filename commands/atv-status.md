---
description: Show Apple TV status — current app, playback, volume, pairing health
---

Run in parallel:
1. `mcp__appletv-dg__appletv_dg_health()` — Pairing-Status, Heartbeat
2. `mcp__appletv-dg__appletv_dg_current_app()` — Aktive App (kann "Unknown" sein wegen tvOS-26-Bug)
3. `mcp__appletv-dg__appletv_dg_playing()` — Wiedergabe-Status + Volume

Format the result as a compact German status block:

```
Apple TV DG Wohnzimmer Esslingen
────────────────────────────────
Status:    <ok|degraded|offline>
App:       <name oder Unknown>
Playback:  <playing|paused|idle>
Volume:    <0–100> %
Heartbeat: <Zeit seit letztem OK>
```

Bei `degraded` oder `offline`: Empfehlung zum Re-Pair geben (Verweis auf `~/Claude/cli-tools/AppleTV_Control/README.md`).

---
description: Set or step the Apple TV volume
argument-hint: <0-100 | up | down | mom>
---

Interpretation of "$1":
- `up` → `mcp__appletv-dg__appletv_dg_volume(action="up")`
- `down` → `mcp__appletv-dg__appletv_dg_volume(action="down")`
- `mom` → `mcp__appletv-dg__appletv_dg_volume(action="set", level=0.35)` (Mom-friendly default ~35 %)
- A number 0..100 → convert to `level = number/100.0` then `action="set"`.
- Anything else → reply with the usage hint and stop.

Report in German: "Lautstärke auf <X> %." or "Lautstärke +1 Stufe."

Mom-Safety: If the resulting absolute level would be > 0.6 AND local time is between 22:00–05:00 Europe/Berlin, ask the user to confirm before sending.

---
description: Route Apple TV audio to HomePod, TV speakers, or both
argument-hint: <homepod|tv|both>
---

Valid targets: `homepod`, `tv`, `both`.

- `homepod` — high-quality RAOP route to HomePod DG Wohnzimmer (gut für Abend, Mom-friendly)
- `tv` — TV speakers only
- `both` — AirPlay multi-room (TV + HomePod synchron)

If "$1" matches → call `mcp__appletv-dg__appletv_dg_audio_route(target="$1")`.
Otherwise → reply with valid targets and stop.

**Mom-Safety:** Before switching while playback is active (`appletv_dg_playing()` returns playing), warn the user that the audio will briefly drop. Proceed only after confirmation if Mom is actively watching.

Report in German: "Audio läuft jetzt über <Target>."

---
description: Launch an app on the Apple TV (by bundle-id or friendly name)
argument-hint: <netflix|prime|youtube|magenta|disney|appletv|spotify|music|<bundle-id>> [--device=dg]
---

Map "$1" to a bundle-id using this table:
- `netflix` → `com.netflix.Netflix`
- `prime` / `amazon` → `com.amazon.aiv.AIVApp`
- `youtube` / `yt` → `com.google.ios.youtube`
- `magenta` / `magentatv` → `de.telekom.magentatv`
- `disney` / `disney+` → `com.disney.disneyplus`
- `appletv` / `tvplus` → `com.apple.TVWatchList`
- `spotify` → `com.spotify.client`
- `music` → `com.apple.TVMusic`
- `ard` → `de.ard.ardmediathek.appletv`
- `zdf` → `de.zdf.appletv`
- `settings` / `einstellungen` → `com.apple.TVSettings`
- Otherwise: treat "$1" as a literal bundle-id (must contain a dot).

Then call `mcp__appletv-dg__appletv_dg_launch_app(bundle_id=<resolved>)`.

After launch, report success in German: "<App-Name> gestartet auf DG Wohnzimmer."
If error: report the pyatv error verbatim and suggest `/atv-status` to check pairing health.

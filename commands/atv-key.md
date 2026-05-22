---
description: Send a navigation key to the Apple TV
argument-hint: <home|menu|select|up|down|left|right|play|pause|play_pause|stop|screensaver>
---

Valid keys: `home`, `menu`, `select`, `up`, `down`, `left`, `right`, `play`, `pause`, `play_pause`, `stop`, `screensaver`.

If "$1" is one of these → call `mcp__appletv-dg__appletv_dg_navigate(key="$1")`.
Otherwise → reply with the valid-keys list and stop.

Report success in one short German sentence: `<Key> gesendet.`

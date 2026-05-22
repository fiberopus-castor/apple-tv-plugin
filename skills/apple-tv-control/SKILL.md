---
name: apple-tv-control
description: Domain knowledge for controlling Percys Apple TV setup via the appletv-dg MCP server. Use when user mentions "Apple TV", "Fernseher", "Mom-TV", "Mom-Esslingen TV", "HomePod-Routing", "Apple-Home-Cinema", "Netflix/Prime/YouTube/Magenta TV starten", "Bildschirmschoner", "AirPlay-Audio", or asks about Apple-TV-Status, Heartbeat-Drift, Re-Pairing, tvOS-26-Bug, Mom-Abendprogramm. Provides bundle-ID lookup, Mom-Safety guards, audio-routing patterns, multi-device design.
license: MIT
metadata:
    author: Percy-Bodo von Oheimb-Loup
    version: 0.1.0
    mcp-server: appletv-dg
---

# Apple TV Control — Domain Knowledge

## Setup-Realität
- **Aktives Gerät:** "DG Wohnzimmer Esslingen" (Mom's TV, tvOS 26.5, 192.168.178.46)
- **Pairing:** AirPlay + Companion + RAOP, Long-Term-Keys in `~/Claude/credentials/AppleTV/dg-wohnzimmer.json`
- **CLI:** `~/.local/bin/atv-dg`, `atv-dg-audio`, `atv-dg-heartbeat`
- **MCP-Server:** `appletv-dg` (Tools: `appletv_dg_launch_app`, `_navigate`, `_volume`, `_current_app`, `_playing`, `_text_input`, `_audio_route`, `_health`)
- **Heartbeat:** systemd-Timer schreibt Drift in `~/.local/state/atv-dg-heartbeat.log` und Flag-File `/tmp/atv-dg-alert`

## Bundle-ID-Tabelle (verbindlich)

| App | Bundle-ID | Notiz |
|---|---|---|
| Netflix | `com.netflix.Netflix` | Mom hat eigenen Account |
| Amazon Prime | `com.amazon.aiv.AIVApp` | |
| YouTube | `com.google.ios.youtube` | |
| Magenta TV | `de.telekom.magentatv` | Mom's Haupt-TV-App |
| Disney+ | `com.disney.disneyplus` | |
| Apple TV+ | `com.apple.TVWatchList` | |
| Spotify | `com.spotify.client` | falls installiert |
| Apple Music | `com.apple.TVMusic` | |
| ARD Mediathek | `de.ard.ardmediathek.appletv` | |
| ZDF Mediathek | `de.zdf.appletv` | inkl. Tagesschau |
| App Store | `com.apple.TVAppStore` | |
| Einstellungen | `com.apple.TVSettings` | |

Nicht-gelistete Apps: NIE raten — User fragen.

## User-Sätze → Aktionen

| User sagt | Aktion |
|---|---|
| "Mach Apple TV an" / "Wecke den Fernseher" | `_navigate(key="home")` (weckt aus Sleep) |
| "Bildschirmschoner an" / "Mom soll schlafen" | `_navigate(key="screensaver")` |
| "Was läuft gerade?" | `_current_app()` + `_playing()` |
| "Netflix starten" / "Netflix für Mom" | `_launch_app("com.netflix.Netflix")` |
| "Tagesschau" / "ZDF Mediathek" | `_launch_app("de.zdf.appletv")` → select |
| "Pause" / "Stop" / "Weiter" | `_navigate(key="pause"|"stop"|"play")` |
| "Leiser" / "Lauter" | `_volume(action="down"|"up")` |
| "Lautstärke 40" | `_volume(action="set", level=0.40)` |
| "Mom-Lautstärke" | `_volume(action="set", level=0.35)` |
| "Auf HomePod umleiten" | `_audio_route(target="homepod")` |
| "TV-Lautsprecher" | `_audio_route(target="tv")` |
| "Synchron beide" | `_audio_route(target="both")` |
| "Suche <begriff>" | erst App im Suche-Modus, dann `_text_input` |

## Mom-Safety-Patterns (verbindlich)

### Schlafzeitfenster
**22:00 – 05:00 Europe/Berlin**: vor Launch oder Volume-Up den User fragen. Bei Volume `level > 0.6` IMMER nachfragen.

### Aktive Wiedergabe
Vor `launch_app` während `_playing()` → "playing": User bestätigen lassen, sonst Mom-Programm wird unterbrochen.

### Audio-Switch im Live-Betrieb
Audio-Routing-Wechsel verursacht 1–2 s Tonabbruch. Bei aktiver Wiedergabe vorab warnen.

### Niemals heimlich
- Keine stillen App-Wechsel
- Keine "Mom merkt das schon nicht"-Aktionen
- Bei Unklarheit lieber fragen als handeln

## Workflows

### Mom-Abendprogramm (gegen 19:30)
1. `_health()` — sicherstellen alles paired
2. `_launch_app("de.zdf.appletv")`
3. ~2 s warten, dann `_navigate("select")` für Tagesschau-Hauptkachel
4. `_volume(action="set", level=0.40)`
5. `_audio_route(target="tv")` (oder "homepod" bei spätem Abend nach 21:30)

### Spätfilm via HomePod (nach 21:30)
1. `_audio_route(target="homepod")` (bessere Bässe, leiser für Nachbarn)
2. `_volume(action="set", level=0.30)`
3. App nach Wunsch starten

### Diagnose bei "geht nicht mehr"
1. `_health()` — prüft alle 3 Protokolle (AirPlay/Companion/RAOP)
2. Heartbeat-Log: `tail -20 ~/.local/state/atv-dg-heartbeat.log` (via Bash)
3. Bei Drift > 30 min: User auf `~/Claude/cli-tools/AppleTV_Control/README.md` Re-Pair-Sektion verweisen
4. tvOS-26-Bug-Symptom: `_current_app` gibt "Unknown" — das ist NORMAL, kein Fehler

## tvOS-26.5-Bug-Awareness
pyatv ≤ 0.17.0 + tvOS 26.x:
- ✅ `launch_app`, `_navigate`, `_volume`, `_audio_route`, `play/pause/stop` funktionieren
- ❌ `_current_app` und `app_list` schlagen fehl → "Unknown"
- Patch `~/Claude/cli-tools/AppleTV_Control/patches/apply_tvos26_fix.sh` ist appliziert

Nicht den User mit "Unknown" verwirren — direkt sagen: "App-Detection ist auf tvOS 26 limitiert (bekannter Bug). Trotzdem: läuft."

## Multi-Device-Design (vorbereitet, noch nicht aktiv)
Künftig: Bonn-Atelier hat 3 Apple TVs. Pattern:
- Credentials je Device: `~/Claude/credentials/AppleTV/<device-id>.json`
- MCP-Server pro Device als separater Eintrag in `.mcp.json` (z.B. `appletv-bn-atelier-1`)
- Slash-Commands akzeptieren `--device=<id>` (heute Default `dg`)

Bei "Apple TV in Bonn" → User informieren dass aktuell nur Esslingen-DG aktiv ist.

## Hard Rules
- KEINE Reboots — nicht supported
- KEIN Power-Off — gibt's nicht via Companion
- KEINE App-Store-Käufe — Touch-ID-Push geht remote nicht
- Credentials NIEMALS loggen, ausgeben oder in Reports kopieren
- Bei Mom-Schlafzeit IMMER fragen vor jeder lauteren/heller-machenden Aktion

## Tool-Referenz (MCP `appletv-dg`)
- `appletv_dg_launch_app(bundle_id: str)` — App per Bundle-ID starten
- `appletv_dg_navigate(key: str)` — home/menu/select/up/down/left/right/play_pause/play/pause/stop/screensaver
- `appletv_dg_volume(action: str, level: float | None)` — set/up/down, level 0.0–1.0
- `appletv_dg_current_app()` — auf tvOS 26 oft "Unknown" (Bug)
- `appletv_dg_playing()` — Wiedergabe-Status + Volume
- `appletv_dg_text_input(text: str)` — Tastatur-Eingabe in aktives Feld
- `appletv_dg_audio_route(target: str)` — homepod/tv/both
- `appletv_dg_health()` — Pairing-Status aller 3 Protokolle

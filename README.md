# apple-tv — Claude-Code-Plugin

Voll-Remote-Kontrolle für Apple TV via `pyatv` + MCP. App-Launch, Navigation, Audio-Routing (HomePod/TV/Both), Companion-Heartbeat. tvOS-26-Bug-Workaround inkludiert. Multi-Device-vorbereitet.

**Aktives Gerät:** "DG Wohnzimmer Esslingen" (Mom's TV, tvOS 26.5)
**Author:** Percy-Bodo von Oheimb-Loup / fiberopus-castor
**License:** MIT
**Repo:** https://github.com/fiberopus-castor/apple-tv-plugin
**CLI-Repo:** https://github.com/fiberopus-castor/appletv-control-cli

## Was ist drin

- **Agent** `apple-tv-controller` — Autonomer Remote-Agent für komplexe Sequenzen
- **6 Slash-Commands** — `/atv-launch`, `/atv-key`, `/atv-volume`, `/atv-audio`, `/atv-status`, `/atv-text`
- **Skill** `apple-tv-control` — Bundle-ID-Tabelle, Mom-Safety-Patterns, Workflows, tvOS-26-Bug-Awareness
- **Hooks** — Mom-Safety-Check (PreToolUse auf `launch_app`) + Heartbeat-Alert-Surface (PostToolUse)
- **MCP-Registrierung** — Plugin-eigene `.mcp.json` bindet den `appletv-dg`-Server ein

## Installation

### Voraussetzungen
1. CLI-Tool installiert: `~/Claude/cli-tools/AppleTV_Control/` (siehe dortiges README)
2. Apple TV gepaired (AirPlay + Companion + RAOP Long-Term-Keys)
3. Credentials abgelegt: `~/Claude/credentials/AppleTV/dg-wohnzimmer.json` (chmod 600)
4. MCP-Server-venv mit `pyatv==0.17.0` und `mcp` installiert

### Plugin aktivieren
Per Marketplace (sobald gelistet):
```
/plugin marketplace add fiberopus-castor/oheimb-plugins
/plugin install apple-tv@oheimb-plugins
```

Lokal direkt (aktuell):
```
ln -sf ~/Claude/plugins/apple-tv ~/.claude/plugins/apple-tv
# dann Claude-Code neu starten
```

### Verifikation
```
/atv-status
```
Erwartete Ausgabe: Status-Block mit Pairing-Health.

## Erste Schritte

```
/atv-launch netflix
/atv-volume 40
/atv-audio homepod
/atv-key home
/atv-status
```

Oder via Agent (natürlich-sprachig):
> "Starte die Tagesschau für Mom und stell die Lautstärke auf Mom-Pegel."

## Slash-Commands im Detail

| Command | Argumente | Zweck |
|---|---|---|
| `/atv-launch` | `<app oder bundle-id>` | App starten (Netflix, Prime, YouTube, Magenta, …) |
| `/atv-key` | `<home\|menu\|select\|up\|…>` | Navigations-Taste |
| `/atv-volume` | `<0-100 \| up \| down \| mom>` | Lautstärke setzen oder stufen |
| `/atv-audio` | `<homepod\|tv\|both>` | Audio-Routing wechseln |
| `/atv-status` | — | Health + App + Playback + Volume |
| `/atv-text` | `<suchstring>` | Text in aktives Eingabefeld senden |

## Mom-Safety

Plugin enthält explizite Schutzpatterns:
- **Schlafzeitfenster 22:00–05:00 Europe/Berlin** → PreToolUse-Hook warnt
- **Aktive Wiedergabe** → Agent fragt vor App-Wechsel
- **Audio-Routing bei Mom-Stream** → vorab Warnung wegen 1–2 s Tonabbruch
- **Keine heimlichen Aktionen** — Skill enthält Hard-Rule "Bei Unklarheit fragen statt handeln"

## Multi-Device-Erweiterung

Heute aktiv: 1 Gerät (`dg` Esslingen).
Vorbereitet für Bonn-Atelier (3 Apple TVs):
1. Credentials je Device: `~/Claude/credentials/AppleTV/<device-id>.json`
2. MCP-Server-Eintrag pro Device in `.mcp.json` (z.B. `appletv-bn-atelier-1`)
3. Slash-Commands erweitern um `--device=<id>` (heute Default `dg`)

## tvOS-26.5-Bug-Awareness

- ✅ Was funktioniert: `launch_app`, alle Navigation-Keys, Volume, Audio-Routing, Play/Pause/Stop
- ❌ Was nicht geht: `current_app` und `app_list` → "Unknown" (bekannter pyatv ≤ 0.17.0-Bug)
- Patch wird vom CLI-Tool automatisch beim Setup appliziert

## Troubleshooting

| Symptom | Erste Aktion |
|---|---|
| `/atv-status` → "offline" | `~/.local/bin/atv-dg-heartbeat` manuell laufen lassen, Log prüfen |
| Heartbeat-Alert-Banner erscheint | Re-Pair laut `~/Claude/cli-tools/AppleTV_Control/README.md` |
| `current_app` "Unknown" | Normal auf tvOS 26, kein Fehler |
| `launch_app` schlägt fehl | Bundle-ID-Tippfehler? Tabelle im Skill checken |
| Audio bleibt auf TV trotz `homepod` | HomePod im selben WLAN? AirPlay-ID in Credentials korrekt? |

## Lizenz

MIT — siehe `LICENSE`.

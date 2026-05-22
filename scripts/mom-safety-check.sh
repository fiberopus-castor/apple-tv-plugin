#!/bin/bash
# Mom-Safety PreToolUse hook for apple-tv plugin.
# Reads tool input from stdin (JSON). If currently in 22:00–05:00 Europe/Berlin AND
# Apple TV is reporting active playback, emit a soft warning (non-blocking).
# Never hard-blocks — Claude can still decide based on context.
set -e

# Read tool-call JSON from stdin (Claude Code hook contract)
INPUT="$(cat 2>/dev/null || true)"

# Compute hour in Europe/Berlin
HOUR=$(TZ="Europe/Berlin" date +%H)

# Quiet hours: 22, 23, 00, 01, 02, 03, 04
case "$HOUR" in
  22|23|00|01|02|03|04)
    echo "MOM-SAFETY: Aktuell Mom-Schlafzeitfenster (${HOUR}:xx Europe/Berlin)." >&2
    echo "MOM-SAFETY: Vor dem Auslösen prüfen ob Mom wirklich noch wach ist." >&2
    ;;
esac

# Check heartbeat alert flag
if [ -f "/tmp/atv-dg-alert" ]; then
  echo "MOM-SAFETY: Heartbeat-Alert aktiv (/tmp/atv-dg-alert existiert) — atv-dg könnte degradiert sein." >&2
fi

# Always exit 0 — advisory only
exit 0

#!/bin/bash
# PostToolUse hook — surfaces atv-dg heartbeat drift to the user.
# Triggered after any mcp__appletv-dg__* tool call.
set -e

ALERT_FILE="/tmp/atv-dg-alert"
HEARTBEAT_LOG="$HOME/.local/state/atv-dg-heartbeat.log"

if [ -f "$ALERT_FILE" ]; then
  echo "" >&2
  echo "[apple-tv plugin] Heartbeat-Alert: $ALERT_FILE existiert." >&2
  echo "[apple-tv plugin] atv-dg könnte nicht funktional sein bis Re-Pair." >&2
  if [ -f "$HEARTBEAT_LOG" ]; then
    echo "[apple-tv plugin] Letzte 3 Heartbeat-Zeilen:" >&2
    tail -3 "$HEARTBEAT_LOG" >&2 2>/dev/null || true
  fi
  echo "[apple-tv plugin] Re-Pair-Anleitung: ~/Claude/cli-tools/AppleTV_Control/README.md (Sektion 'Wiederherstellung')" >&2
fi

exit 0

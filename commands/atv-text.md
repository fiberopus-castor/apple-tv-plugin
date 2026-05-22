---
description: Send text input to the Apple TV (e.g. into a search field)
argument-hint: <suchstring>
---

Take the full "$ARGUMENTS" string (everything after the command). If empty → reply with usage hint.

Call `mcp__appletv-dg__appletv_dg_text_input(text="$ARGUMENTS")`.

**Voraussetzung:** Auf dem Apple TV muss bereits ein Eingabefeld aktiv sein (z.B. Netflix-Suche, YouTube-Suche). Falls unsicher: vorher `/atv-launch netflix` → `/atv-key select` (auf Suche-Icon) → dann erst `/atv-text`.

Report in German: "Text gesendet: \"<text>\"."

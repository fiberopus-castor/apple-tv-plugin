#!/usr/bin/env bash
# Apple-TV-Plugin Bootstrapper
#
# Modi:
#   ./install.sh bootstrap           - clone CLI-Tool + venv + symlinks (idempotent)
#   ./install.sh restore-credentials - restic restore aus B2 wenn ENV vorhanden
#   ./install.sh verify              - Pre-Flight-Check
#   ./install.sh                     - bootstrap + verify
#
# Sicherheit:
# - Es werden NIEMALS Credentials in stdout/log geechoed
# - Symlink-Targets werden vor Ueberschreiben geprueft (kein Hijack)
# - Credentials-Files werden chmod 600 gesetzt
set -euo pipefail

# ---------- Konfiguration ----------
CLI_REPO_URL="${ATV_CLI_REPO_URL:-https://github.com/fiberopus-castor/appletv-control-cli.git}"
CLI_DIR="${ATV_CLI_DIR:-${HOME}/Claude/cli-tools/AppleTV_Control}"
CRED_DIR="${ATV_CRED_DIR:-${HOME}/Claude/credentials/AppleTV}"
CRED_FILE="${CRED_DIR}/dg-wohnzimmer.json"
BIN_DIR="${HOME}/.local/bin"
RESTIC_ENV="${HOME}/Claude/credentials/CastorOS/restic-credentials.env"
SYMLINKS=("atv-dg" "atv-dg-audio" "atv-dg-with-homepod")

# ---------- Logging ----------
log()  { printf '[install] %s\n' "$*"; }
ok()   { printf '  \033[32mPASS\033[0m  %s\n' "$*"; }
warn() { printf '  \033[33mWARN\033[0m  %s\n' "$*"; }
fail() { printf '  \033[31mFAIL\033[0m  %s\n' "$*"; }

# ---------- Helper ----------
have_cmd() { command -v "$1" >/dev/null 2>&1; }

ensure_symlink() {
    local name="$1"
    local target="$2"
    local link="${BIN_DIR}/${name}"
    if [ ! -e "$target" ]; then
        warn "Symlink-Target fehlt: $target (skip)"
        return 0
    fi
    if [ -L "$link" ]; then
        local cur
        cur="$(readlink "$link")"
        if [ "$cur" = "$target" ]; then
            ok "Symlink ${name} bereits korrekt"
            return 0
        fi
        log "Symlink ${name} zeigt auf ${cur}, korrigiere -> ${target}"
        ln -sfn "$target" "$link"
        ok "Symlink ${name} aktualisiert"
        return 0
    fi
    if [ -e "$link" ]; then
        warn "${link} existiert und ist KEIN Symlink — uebersprungen (manuell pruefen)"
        return 0
    fi
    ln -s "$target" "$link"
    ok "Symlink ${name} angelegt"
}

# ---------- Subcommands ----------
cmd_bootstrap() {
    log "== bootstrap =="

    # 1. Pflicht-Checks
    for c in git python3; do
        if ! have_cmd "$c"; then
            fail "Pflicht-Tool fehlt: $c"
            exit 1
        fi
    done
    if ! python3 -c "import venv" 2>/dev/null; then
        fail "python3-venv nicht installiert (apt install python3-venv)"
        exit 1
    fi
    ok "Tooling: git, python3, python3-venv vorhanden"

    # 2. CLI-Tool
    mkdir -p "$(dirname "$CLI_DIR")"
    if [ -d "${CLI_DIR}/.git" ]; then
        log "CLI-Tool vorhanden — pull"
        git -C "$CLI_DIR" pull --ff-only || warn "git pull nicht moeglich (offline?), fahre fort"
        ok "CLI-Tool aktualisiert: ${CLI_DIR}"
    else
        log "CLI-Tool klonen nach ${CLI_DIR}"
        git clone "$CLI_REPO_URL" "$CLI_DIR"
        ok "CLI-Tool geklont"
    fi

    # 3. venv
    local venv_dir="${CLI_DIR}/venv"
    if [ -f "${venv_dir}/bin/activate" ]; then
        ok "venv bereits vorhanden: ${venv_dir}"
    else
        log "Erzeuge venv unter ${venv_dir}"
        python3 -m venv "$venv_dir"
        ok "venv erzeugt"
    fi
    # pyatv + flask + mcp idempotent installieren (pip ist von Natur aus idempotent)
    log "Installiere/aktualisiere Python-Abhaengigkeiten (pyatv, flask, mcp)"
    "${venv_dir}/bin/pip" install --quiet --upgrade pip
    "${venv_dir}/bin/pip" install --quiet pyatv flask mcp || {
        warn "pip install mcp fehlgeschlagen — versuche ohne mcp"
        "${venv_dir}/bin/pip" install --quiet pyatv flask
    }
    ok "Python-Abhaengigkeiten OK"

    # 4. tvOS-26-Patch
    local patch="${CLI_DIR}/patches/apply_tvos26_fix.sh"
    if [ -x "$patch" ] || [ -f "$patch" ]; then
        log "Wende tvOS-26-Patch an (idempotent)"
        bash "$patch" || warn "Patch-Script gab Non-Zero zurueck (eventuell schon angewandt)"
        ok "tvOS-26-Patch ausgefuehrt"
    else
        warn "Patch-Script nicht gefunden: $patch (skip)"
    fi

    # 5. Symlinks
    mkdir -p "$BIN_DIR"
    for s in "${SYMLINKS[@]}"; do
        ensure_symlink "$s" "${CLI_DIR}/bin/${s}"
    done

    log "Bootstrap fertig."
}

cmd_restore_credentials() {
    log "== restore-credentials =="
    mkdir -p "$CRED_DIR"
    chmod 700 "$CRED_DIR" || true

    if [ ! -f "$RESTIC_ENV" ]; then
        warn "B2-Backup-ENV nicht gefunden unter ${RESTIC_ENV}"
        cat <<'EOF'

Manueller Pairing-Pfad:
  1. atv-dg pair                 (am physischen Apple TV)
  2. dg-wohnzimmer.json nach ~/Claude/credentials/AppleTV/ legen
     chmod 600 ~/Claude/credentials/AppleTV/dg-wohnzimmer.json
  3. Siehe README.md "Multi-Host-Installation" fuer Details
EOF
        return 1
    fi

    if ! have_cmd restic; then
        fail "restic nicht installiert (apt install restic)"
        return 1
    fi

    log "Lade restic-ENV (Inhalt nicht geloggt)"
    # shellcheck disable=SC1090
    set +x
    source "$RESTIC_ENV"

    log "Stelle Credentials aus restic-Snapshot wieder her"
    # Pfad-Filter zwingend, damit wir nicht das ganze /home wiederherstellen
    restic restore latest \
        --target / \
        --include "${HOME}/Claude/credentials/AppleTV" \
        >/dev/null
    ok "restic restore abgeschlossen"

    if [ ! -s "$CRED_FILE" ]; then
        fail "Credential-File nach Restore leer oder fehlt: ${CRED_FILE}"
        return 1
    fi
    chmod 600 "$CRED_FILE"
    ok "Credentials wiederhergestellt + chmod 600"
}

cmd_verify() {
    log "== verify =="
    local rc=0

    # 1. Symlinks
    for s in "${SYMLINKS[@]}"; do
        if have_cmd "$s"; then
            ok "Binary auf PATH: $s"
        else
            fail "Binary nicht auf PATH: $s (ist ~/.local/bin im PATH?)"
            rc=1
        fi
    done

    # 2. Credentials
    if [ -f "$CRED_FILE" ]; then
        local mode
        mode="$(stat -c '%a' "$CRED_FILE" 2>/dev/null || stat -f '%Lp' "$CRED_FILE")"
        if [ "$mode" = "600" ]; then
            ok "Credentials vorhanden + chmod 600"
        else
            fail "Credentials-Mode ist $mode, erwartet 600"
            rc=1
        fi
        if [ -s "$CRED_FILE" ]; then
            ok "Credentials nicht leer"
        else
            fail "Credentials-File ist leer"
            rc=1
        fi
    else
        fail "Credentials fehlen: $CRED_FILE"
        rc=1
    fi

    # 3. atv-dg ausfuehrbar
    if have_cmd atv-dg; then
        if atv-dg --help >/dev/null 2>&1 || atv-dg --version >/dev/null 2>&1; then
            ok "atv-dg ausfuehrbar"
        else
            warn "atv-dg gibt keinen sauberen --help/--version-Status (eventuell ok wenn Wrapper-only)"
        fi
    fi

    # 4. Plugin-Registry
    local reg="${HOME}/.claude/plugins/installed_plugins.json"
    if [ -f "$reg" ] && grep -q '"apple-tv"' "$reg" 2>/dev/null; then
        ok "Plugin in installed_plugins.json registriert"
    else
        warn "Plugin nicht in $reg gefunden (bei lokaler Dev-Installation normal)"
    fi

    if [ "$rc" -eq 0 ]; then
        log "verify: ALL PASS"
    else
        log "verify: FAIL"
    fi
    return $rc
}

# ---------- Dispatch ----------
case "${1:-default}" in
    bootstrap)            cmd_bootstrap ;;
    restore-credentials)  cmd_restore_credentials ;;
    verify)               cmd_verify ;;
    default|"")           cmd_bootstrap && cmd_verify ;;
    -h|--help|help)
        sed -n '2,11p' "$0"
        ;;
    *)
        printf 'Unbekanntes Subcommand: %s\n' "$1" >&2
        sed -n '2,11p' "$0" >&2
        exit 2
        ;;
esac

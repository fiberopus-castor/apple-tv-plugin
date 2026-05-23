# Changelog

## [0.2.1] — 2026-05-23

### Changed
- README "Multi-Host-Installation" auf neuen Marketplace-Slug `@CastorOS` umgestellt (vorher `@oheimb-plugins` — deprecated nach CastorOS Naming Standard 2026-05-23).

## [0.2.0] — 2026-05-22

### Added
- `scripts/install.sh` — idempotenter Multi-Host-Bootstrapper (`bootstrap` / `restore-credentials` / `verify`)
- README-Sektion "Multi-Host-Installation" mit Komponenten-Mapping und Subcommand-Tabelle

### Changed
- `marketplace.json`: apple-tv-Eintrag auf `0.2.0` gebumpt + Description ergaenzt

### Compatibility
- Requires CLI-Tool `appletv-control-cli` v0.1.1+ (Stdout-Fix fuer MCP-Handshake)

### Security
- `install.sh` loggt keine Credentials oder restic-ENV in stdout
- Symlink-Targets werden vor `ln` geprueft (Schutz vor Symlink-Hijack)
- Credentials-Files erhalten `chmod 600`

## [0.1.0] — 2026-05-22

Initial release.

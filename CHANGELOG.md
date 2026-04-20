# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.16.0] - 2026-04-19

### Added
- **Self-install security upgrade (v2)**:
  - New function `perform_self_install_v2()` with layered checksum verification.
  - If `CHECKSUM=<sha256>` environment variable is set, the downloaded script is strictly verified against it before installation.
  - If no `CHECKSUM` is provided, the script automatically attempts to fetch and verify `${SCRIPT_URL}.sha256` (when available).
  - On checksum mismatch → immediate `die()` with clear security error (prevents tampered downloads).
  - Full defensive comment block documenting the v2 procedure, rationale, and upgrade from previous version.
- Support for `--no-cloudflare` flag to disable Cloudflare IP restriction during setup.

### Changed
- `perform_self_install()` renamed to `perform_self_install_v2()` (old name preserved in comments for clarity).
- Improved domain handling logic in interactive mode (main domain is now explicitly chosen by the user and always placed first).
- Self-update and installation paths now use the new v2 function (minimal change, backward-compatible behavior preserved).

### Fixed
- **Critical fix for certificate expansion**: When adding new domains to an existing Let's Encrypt certificate, Certbot no longer fails with the "expand" confirmation prompt in non-interactive mode.
  - Added `--expand` + `--cert-name` to the primary `certbot certonly` call.
  - Added safe fallback for first-time certificate issuance.
  - Added detailed "LESSON LEARNED" comment block in `apply_letsencrypt_standalone()`.

## [1.15.0] - 2026-04-19

### Added
- **nginx-adm least-privilege model** (matured and stabilized):
  - Dedicated `nginx-adm` system user (fixed UID/GID 1999, home at `/etc/nginx-adm`).
  - Ownership separation: `nginx-adm` owns all configuration files and directories.
  - Symlink strategy between standard `/etc/nginx` paths and `/etc/nginx-adm`.
  - Restricted sudoers rules (only `systemctl` commands for nginx + `nginx -t`, NOPASSWD).
- `create_nginx_adm_user()`, `setup_nginx_adm_ownership()`, and `setup_restricted_sudoers()` functions.
- Dated backup system for nginx configs in `sites-available/` with special handling for `default.conf` (backup then remove to prevent accumulation).
- `detect_nginx_platform_paths()` and related diagnostics for future cross-platform support (Debian, RHEL, Alpine, macOS Homebrew).
- Improved idempotency across installation and setup functions (early exits when components already exist).
- Cloudflare protection is now optional and prompted interactively (with "DNS Only" warning during cert issuance).
- Debug page at `https://<main-domain>/cloudflare-check` for verifying Cloudflare detection.

### Changed
- **Strict sequence enforcement** strengthened in both interactive and non-interactive modes.
- Non-interactive mode (`no TTY`) now performs safe install-only flow + `nginx-adm` setup + early nginx stop (no certs or config).
- `run_interactive_setup()` and `run_non_interactive_setup()` clearly separated.
- Cloudflare IP ranges and real-IP handling updated and hardened (real-server tested `$is_cf` logic).
- Better platform detection for Certbot and Nginx installation (snap, apt, apk, dnf/yum, brew).
- Centralized output system (`output_text()` / `output_json()`) made more robust.

### Fixed
- Permission and ownership issues after nginx-adm introduction.
- Repeated runs no longer accumulate default configs or break symlinks.
- Certificate expansion reliability when domains are added later.
- Graceful handling for non-root diagnostic commands (`domains`, `email`, `about`).
- Various small robustness improvements (idempotency, defensive pre-creation of `/etc/letsencrypt`).

## [1.13.0] - 2026-04-15

### Added
- Initial nginx-adm least-privilege foundations.
- Dated backup system for existing nginx configs.
- Cloudflare proxy detection question.
- Cross-platform support improvements.
- Quiet and JSON output modes.
- Defensive pre-creation of `/etc/letsencrypt` structure.

### Changed
- Major security refactoring (reduced ongoing root dependency).
- Strict installation sequence enforced.
- Updated Cloudflare IP ranges (April 2026).

### Fixed
- Permission and ownership issues.
- Non-interactive mode handling.

## [1.1.1] - 2026 (earlier version)

### Added
- Initial domain confirmation flow.
- Basic standalone Certbot + Nginx setup.
- Self-install logic.

---

**Previous versions** (before 1.1.1) were not tracked in this changelog.
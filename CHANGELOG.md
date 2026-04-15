# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Support for `--no-cloudflare` flag to disable Cloudflare IP restriction during setup.

### Changed
- Improved domain handling logic in interactive mode (main domain is now explicitly chosen by the user and always placed first).

### Fixed
- **Critical fix for certificate expansion**: When adding new domains (e.g. `slip.nifty-corner.com`) to an existing Let's Encrypt certificate, Certbot no longer fails with the "expand" confirmation prompt in non-interactive mode.
  - Added `--expand` + `--cert-name` to the primary `certbot certonly` call.
  - Added safe fallback for first-time certificate issuance.
  - Added detailed "LESSON LEARNED" comment block in `apply_letsencrypt_standalone()` to prevent regression.

## [1.13.0] - 2026-04-15

### Added
- Full nginx-adm least-privilege model (dedicated user, restricted sudoers, ownership separation).
- Dated backup system for existing nginx configs (with special handling for `default.conf`).
- Cloudflare proxy detection question during interactive setup.
- Cross-platform support improvements (better detection for Alpine, RHEL, macOS, etc.).
- Quiet and JSON output modes for better scripting/automation support.
- Defensive pre-creation of `/etc/letsencrypt` structure.

### Changed
- Major refactoring for security and maintainability (reduced root dependency after initial setup).
- Strict installation sequence enforced (install → stop nginx → handle email/domains → certs → config).
- Updated Cloudflare IP ranges (April 2026).

### Fixed
- Various permission and ownership issues.
- Better handling of non-interactive mode.

## [1.1.1] - 2026 (earlier version)

### Added
- Initial domain confirmation flow.
- Basic standalone Certbot + Nginx setup.
- Self-install logic.

---

**Previous versions** (before 1.1.1) were not tracked in this changelog.
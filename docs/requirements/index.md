# Requirements index

**Product:** certbot-nginx (POSIX `/bin/sh` Type 0 online self-managed CLI + Nginx/Certbot domain)  
**Workspace state:** Specialized product law (not blank genesis); **software-development class** + **domain SSOT present**.  
**Bootstrap origin (A):** selfmanaged → **leaf (B):** certbot-nginx.  
**Class law:** `requirement-class-software-dev` / **`RQ-CLASS-SOFTWARE-DEV`**.  
**Domain SSOT:** `requirement-domain-certbot-nginx` / **`RQ-DOMAIN-CERTBOT-NGINX`**.  
**Updated:** 2026-08-12

| Requirement-ID | Key | Title | Area | Status | Path | Updated |
|----------------|-----|-------|------|--------|------|---------|
| `RQ-CLASS-SOFTWARE-DEV` | requirement-class-software-dev | Software-development class law + residual stack (posix-sh Type 0) | class | Active | `requirement-class-software-dev.md` | 2026-08-12 |
| `RQ-BOOTSTRAP-CHAIN` | requirement-bootstrap-chain | Bootstrap chain (selfmanaged → certbot-nginx; A→B only) | architecture | Active | `requirement-bootstrap-chain.md` | 2026-08-12 |
| `RQ-SHELL-AUTOMATIC-CHECKSUM` | requirement-shell-automatic-checksum | Automatic companion-digest integrity | shell | Active | `requirement-shell-automatic-checksum.md` | 2026-08-12 |
| `RQ-SHELL-CLI-INTERFACE` | requirement-shell-cli-interface | Shell CLI interface (commands, flags, dispatch, modes) | shell | Active | `requirement-shell-cli-interface.md` | 2026-08-12 |
| `RQ-SHELL-CLI-STORAGE` | requirement-shell-cli-storage | Scratch/cache storage resolve | shell | Active | `requirement-shell-cli-storage.md` | 2026-08-12 |
| `RQ-SHELL-CLI-ZERO-ARGUMENTS` | requirement-shell-cli-zero-arguments | Empty argv Type O install-ensure | shell | Active | `requirement-shell-cli-zero-arguments.md` | 2026-08-12 |
| `RQ-DOMAIN-CERTBOT-NGINX` | requirement-domain-certbot-nginx | Nginx + Certbot + Cloudflare + nginx-adm domain law (four pillars; EM-EXT) | domain | Active | `requirement-domain-certbot-nginx.md` | 2026-08-12 |
| `RQ-SHELL-IDEMPOTENCY` | requirement-shell-idempotency | Shell idempotency / re-run safety | shell | Active | `requirement-shell-idempotency.md` | 2026-08-12 |
| `RQ-SHELL-INTERACTIVE-VS-NONINTERACTIVE` | requirement-shell-interactive-vs-noninteractive | Interactive vs non-interactive / curl\|sh | shell | Active | `requirement-shell-interactive-vs-noninteractive.md` | 2026-08-12 |
| `RQ-SHELL-MODULAR-FUNCTION-DESIGN` | requirement-shell-modular-function-design | Single-file modular function design | shell | Active | `requirement-shell-modular-function-design.md` | 2026-08-12 |
| `RQ-SHELL-OUTPUT-REQUIREMENTS` | requirement-shell-output-requirements | Central output SSOT (human/JSON modes) | shell | Active | `requirement-shell-output-requirements.md` | 2026-08-12 |
| `RQ-SHELL-SELF-MANAGEMENT` | requirement-shell-self-management | Self-management lifecycle (version-check, update, uninstall, about) | shell | Active | `requirement-shell-self-management.md` | 2026-08-12 |

**Rules for agents:**

1. Treat rows above as the **live product-law inventory** for certbot-nginx.  
2. **Primary citation** uses **Requirement-ID** (`RQ-*`) on product surfaces; path/basename secondary.  
3. **Do not invent** additional `requirement-*.md` paths — verify on disk and add a registry row in the same change when creating one.  
4. Product source comments cite **only** these live requirement files — never `template-*` / `skill-*` as behavioral authority.  
5. This versioned surface lists **requirement rows only** — no harness tree dumps.  
6. Keep Status and Path in sync with each file’s header when status changes.  
7. **Domain naming:** Exactly one Active domain SSOT: `requirement-domain-certbot-nginx` / `RQ-DOMAIN-CERTBOT-NGINX`.  
8. **Bootstrap direction:** selfmanaged → certbot-nginx only (`RQ-BOOTSTRAP-CHAIN`). Never reverse-copy.

When adding a requirement: append a row (with `RQ-*`), create the file under `docs/requirements/`, keep Status in sync with the file header.

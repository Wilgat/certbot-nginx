**file**: docs/requirements/requirement-domain-certbot-nginx.md  
**Requirement-ID**: `RQ-DOMAIN-CERTBOT-NGINX`  
**Status**: Active (Version 1.1.0 – elev model + webserver/ssl notes)  
**Area**: domain  
**Key**: `requirement-domain-certbot-nginx`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **Single Source of Truth (SSOT)** for the product’s **domain law** on the specialized shell CLI: specialized subcommands, specialized features, specialized help items, and specialized about items—beyond Type 0 install/self-management inherited from bootstrap **selfmanaged**.

**SSOT rule:** Exactly one Active domain-requirements file is current domain law (this file).  
**Scope:** Nginx + Certbot + Cloudflare origin protection + nginx-adm least-privilege host setup and domain diagnostics.  
**Out of scope:** Type 0 CLI binary lifecycle (install, version-check, self-update, self-uninstall, empty-argv Type O) — peer shell requirements.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Domain SSOT (portable)

| Rule | MUST |
|------|------|
| **One current SSOT** | At most one Active `requirement-domain-*` is current domain law |
| **Registry** | One Active row in `docs/requirements/index.md` with Area **domain** |
| **Not Type 0** | Domain host mutation is **not** empty-argv install-ensure |
| **Privilege** | Host-mutating domain paths **MUST** require root (or documented escalation) before mutation |
| **Output** | Domain messages via product output helpers (`info`/`success`/`error`/`output_json` family) |

### 2.2 Specialized CLI subcommands (portable)

Domain verbs **MUST**:

1. Route through the single dispatcher (`main_certbot_nginx_app`).  
2. Preserve Type 0 routes (install, version, about, version-check, self-update, self-uninstall, help, empty-argv Type O).  
3. Fail closed on missing prerequisites with clear human/JSON errors.  
4. Appear accurately in `help`.

### 2.3 Specialized features (portable)

Domain law **MUST** define (when claimed):

| Topic | Requirement |
|-------|-------------|
| Certificate issuance | Let's Encrypt via Certbot **standalone** (not live `certbot --nginx` edit of configs as sole path) |
| Main domain / CN | User-chosen primary domain becomes certificate CN; SAN list ordered accordingly |
| Persistence | Email and domains stored under `/etc/letsencrypt/` with defensive re-create of missing placeholders |
| Cloudflare origin | Default enable Cloudflare-only origin protection; disable with `--no-cloudflare` |
| Least privilege | Dedicated **nginx-adm** user owns nginx conf tree; restricted sudoers for nginx service only |
| Backups | Dated backups of nginx site configs before destructive config writes |
| Sequence | Packages → stop nginx early → email/domains → obtain certs → deploy configs → test/start |
| Host-mutating privilege | Verbs `setup` / `run` / `nginx-conf` **MUST** call root gate on **every** path (interactive, non-interactive, JSON) **before** first host write; non-root → non-zero, **no partial host mutation**; empty argv is Type O only (not host setup) |

### 2.4 Specialized project help items (portable)

`help` **MUST**:

1. List domain verbs with one-line purpose.  
2. List Type 0 self-management accurately (no foreign product DNA: timer, Java, Maven, pom.xml).  
3. State empty argv = Type O install-ensure; domain full setup = `setup` / `run`.  
4. Document `--no-cloudflare` and force reinstall flags as designed.

### 2.5 Specialized project about items (portable)

`about` **MUST**:

1. Retain Type 0 diagnostics (install presence/paths, user, shell, TTY).  
2. **May** include nginx platform detection (config roots, sites-available/enabled).  
3. **MUST NOT** expose `CHECKSUM` pin values as about secrets.

### 2.6 Implementation Notes (this project — certbot-nginx)

| Item | Value |
|------|--------|
| **Domain SSOT file** | This file: `requirement-domain-certbot-nginx.md` |
| **Product / APP_NAME** | `certbot-nginx` |
| **Ship unit** | `./certbot-nginx` |
| **Bootstrap A** | `selfmanaged` (Type 0 online self-managed CLI) — domain law applies to **leaf only** |
| **Dispatcher** | `main_certbot_nginx_app` |
| **Domain function style** | Host setup helpers (`run_interactive_setup`, `run_non_interactive_setup`, `deploy_domain_nginx_configs`, `create_nginx_adm_user`, …) — not Type 0 `inst_*` names |
| **Elev model (host-mutating)** | **EM-EXT** (external elev): operator runs `sudo certbot-nginx setup` / `run` / `nginx-conf` (or already-root); tool **root-gates** and **MUST NOT** use in-tool password-sudo as the primary setup elev path |
| **Elev model IDs not chosen** | **EM-INT** / **EM-HYB** are **not** product law unless this requirement is explicitly revised |

#### Specialized CLI subcommands (certbot-nginx)

| Command | Handler / path | Required behavior |
|---------|----------------|-------------------|
| `setup` | `run_interactive_setup` / `run_non_interactive_setup` | Full Nginx + Certbot domain setup; **EM-EXT** — root required before host mutation |
| `run` | same as `setup` | Alias for setup |
| `domains` | `show_domains` | Display configured domains from persistent store (read path; no host package mutation) |
| `email` | `show_email` | Display Let's Encrypt email from persistent store (read path) |
| `nginx-conf` | deploy path after load domains | Re-generate nginx site configs only; **EM-EXT** root; requires prior domain setup; backup + validate before enable/reload |

**Not domain:** empty argv, `install`, `version`, `version-check`, `self-update`, `self-uninstall`, `about`, `help` — Type 0 / CLI surface.

#### Specialized features (certbot-nginx)

| Feature | Law |
|---------|-----|
| **Certbot mode** | `--standalone`; strict order: obtain certs **before** full nginx config deploy that assumes live TLS paths |
| **Main domain** | Interactive confirmation of primary CN; file-backed domain list |
| **Email** | Collected independently; persisted under Let's Encrypt tree |
| **Cloudflare** | Default `USE_CLOUDFLARE=1`; official CF IP ranges + deny non-CF; `--no-cloudflare` opt-out |
| **nginx-adm** | Create least-privilege user; own conf tree; restricted sudoers (nginx systemctl only); `nginx -t` as nginx-adm |
| **Backups** | Dated `.YYYYMMDD-N.bak` style backups before site config rewrite |
| **Syntax validate before reload** | After writing or enabling site configs, **MUST** run `nginx -t` (or equivalent config test) **before** `reload` / `restart` / `start` that applies the new configs; fail closed on test failure (keep prior enabled set when designed) |
| **Certificate storage** | Live certs/keys under system Let's Encrypt layout (e.g. `/etc/letsencrypt/…`); **MUST NOT** copy private keys into world-readable product scratch or `util_resolve_storage` trees; permissions remain Certbot/OS defaults unless a specialized hardening REQ is added |
| **Certificate renewal** | Rely on **Certbot renew** / platform timer or documented operator renew path; product **MUST NOT** claim silent zero-downtime multi-node orchestration; re-run `nginx-conf` / setup paths **MUST** remain safe after renew when cert paths unchanged (idempotent conf deploy) |
| **External webserver posture** | Production path is **system Nginx** managed via configs + nginx-adm — not an embedded app-only listener as the primary product mode |
| **Platforms** | Primary Linux (Debian/Ubuntu, Alpine, RHEL family); macOS best-effort install only |

#### Specialized project help items (certbot-nginx)

`help` **MUST** include:

- Type O empty argv / `install`  
- Domain: `setup` / `run`, `domains`, `email`, `nginx-conf`  
- Type 0: `about`, `version`, `version-check`, `self-update`, `self-uninstall`, `help`  
- Options: `--quiet`, `--json`, `--force`/`--reinstall`, `--no-cloudflare`  
- Note that host setup is **not** bare empty argv  

#### Specialized project about items (certbot-nginx)

| Field | Law |
|-------|-----|
| Type 0 diagnostics | Install presence, paths, user, shell, TTY — required |
| Domain extras | Nginx platform detection block (roots, sites dirs) is **allowed** |
| CHECKSUM | **MUST NOT** appear as secret value in about |

#### Gaps / compliance (honest)

| Item | Status |
|------|--------|
| Output family | Uses `info`/`msg`/`output_json` (not pure `out_*` naming from bootstrap); messages still centralized — long-term align when refactor authorized |
| Downgrade gate on self-update | Equality no-op present; strict older-than-local refuse may be weaker than pure selfmanaged — track under shell self-management |
| Automated domain tests suite | Not yet present under `tests/` — gap for future `skill-add-tests` |
| Dedicated renew verb | No product-owned `renew` subcommand required; operator/Certbot renew is the intended path unless a future REQ adds one |
| Multi-node zero-downtime | **Out of scope** — single-host setup product |

### 2.7 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution:** Root gates, backups, cert-before-config sequence.  
- **CIAO Principle 2 – Intentional:** Domain verbs separate from Type 0 lifecycle.  
- **CIAO Principle 5 – SSOT:** One domain law file for four pillars.  
- **CIAO Principle 9 – Command types:** Domain host ops are privileged; CLI self-care is Type 0.  
- **CIAO Principle 10 – Least privilege:** nginx-adm model.  
- **CIAO Principle 4 / 20 – Over-protect:** No reverse-copy of domain onto bootstrap selfmanaged.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Fail closed when domains/email missing for `nginx-conf`.  
- **Intentional:** Explicit `setup` for host mutation.  
- **Anti-fragile:** Dated backups; platform detection; non-interactive path for automation.  
- **Over-protect:** Cloudflare default deny; restricted sudoers; CIAO Protection Zones in ship unit.

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Route full host Nginx/Certbot setup through empty argv (breaks Type O).  
1b. Allow non-root (or non-elevated) `setup`/`run`/`nginx-conf` to mutate the host or partially write `/etc` / services (host-mutating domain privilege).  
1c. Switch primary elev model away from **EM-EXT** (e.g. invent in-tool password-sudo for whole setup as default) without explicit requirement redesign.  
2. Reverse-copy domain law or domain verbs into bootstrap **selfmanaged**.  
3. Remove nginx-adm least-privilege model without explicit redesign order.  
4. Replace standalone cert flow with silent live `certbot --nginx` edits without authorized REQ change.  
5. Ship help/about text from foreign products (timer, Java/Maven, pom.xml).  
6. Disable Cloudflare protection by default without requirement + README honesty.  
7. Drop dated backups before destructive nginx config writes.  
7b. Enable or reload nginx configs **without** a successful config test (`nginx -t` or equivalent) after material conf changes.  
7c. Place private keys into world-readable scratch/cache storage roots owned by Type 0 storage resolve.  
8. Cite templates/skills as product-source behavioral authority.

---

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-class-software-dev.md` | Class gate |
| `docs/requirements/requirement-bootstrap-chain.md` | Lineage A→B |
| `docs/requirements/requirement-shell-cli-interface.md` | Type 0 + dispatch peers |
| `docs/requirements/requirement-shell-cli-zero-arguments.md` | Empty argv Type O |
| `docs/requirements/requirement-shell-self-management.md` | Lifecycle |
| `./certbot-nginx` | Ship unit under test |
| Root `README.md` | User-facing channel + setup docs |

**Last Updated**: 2026-08-12  
**Owner**: certbot-nginx project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).

**file**: docs/requirements/requirement-shell-cli-storage.md  
**Requirement-ID**: `RQ-SHELL-CLI-STORAGE`  
**Status**: Active (Version 1.1.0 – cache folder **and** persistence folder)  
**Area**: shell  
**Key**: `requirement-shell-cli-storage`  
**Philosophy**: CIAO / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **shell CLI storage** of the certbot-nginx POSIX `/bin/sh` CLI. **Storage** means **two** classes, not cache alone:

| Class | Role | Live path shape |
|-------|------|-----------------|
| **Cache folder** | Volatile scratch / temps / staging | Resolve chain in §2.2 (`util_resolve_storage`) |
| **Persistence folder** | Durable per-user app data | `${HOME}/.local/certbot-nginx` (`util_resolve_persistent_storage`) |

It owns path **shapes**, central resolvers, `main_certbot_nginx_app` wire, and `about` diagnostics for **both** classes.

**Scope:** Cache resolve priority; persistence folder create-before-return; isolation; `EFFECTIVE_STORAGE_DIR` / `PERSISTENT_STORAGE_DIR` / `TMPDIR` export; about human + JSON fields.  
**Out of scope (cited, not re-owned):** Binary install paths (`USER_BIN` = `${HOME}/.local/bin` / `GLOBAL_BIN`); domain host paths (Nginx site trees, Let's Encrypt live certs/keys, nginx-adm home) — those stay under domain / OS layout; companion checksum; PATH shell-rc.

### 1.1 Human-facing

**In one sentence:** You run `certbot-nginx about` and the program names its own folders: three cache-folder candidates plus the one **in use**, and a **persistence folder** at `${HOME}/.local/certbot-nginx` for durable per-user data.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Folders this program creates for **you** | Cache under `/dev/shm`, `/tmp`, or the user cache; persistence under `${HOME}/.local/certbot-nginx` |
| The other role | nginx-adm / host Let's Encrypt trees | Live certs and site configs stay there |
| Not this file | Install binary location, Nginx sites, live keys | `${HOME}/.local/bin` is the install bin, not persistence |

| Includes | Excludes |
|----------|----------|
| Cache folder resolve (preferred `/dev/shm` → `/tmp` → user cache) + persistence folder `${HOME}/.local/certbot-nginx` | Install bin (`USER_BIN` / `GLOBAL_BIN`); `/var/…` host deposit; Nginx/Let's Encrypt live material |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./certbot-nginx` | program file | live resolvers |
| `certbot-nginx about` | command | cache + persistence lines |
| `certbot-nginx --json about` | command | `cache_preferred` / `cache_tmp` / `cache_fallback` / `persistence_storage` / `effective_storage` |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Ask the program where it keeps files | Human mode prints **Cache folder (preferred)** / **Cache folder (tmp)** / **Cache folder (fallback)** / **Cache folder (in use)** / **Persistence storage**. JSON names the same five plus `storage_dir`. The persistence folder is **not** the install bin. | `certbot-nginx about` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Two storage classes (mandatory)

1. Product law **MUST** name **both** the **cache folder** and the **persistence folder**. Cache-only wording is incomplete.  
2. **MUST** keep **one** authoritative cache-resolve helper: **`util_resolve_storage`**.  
3. **MUST** keep **one** authoritative persistence helper: **`util_resolve_persistent_storage`** (path printer **`util_persistent_storage_dir`**).  
4. New code that needs a product scratch/cache **root** **MUST** call `util_resolve_storage` (or `mktemp` under a path it returned) — **MUST NOT** introduce parallel hard-coded `/tmp/certbot-nginx` dumps.  
5. New code that needs Type 0 durable per-user app data **MUST** call `util_resolve_persistent_storage` — **MUST NOT** invent a second persistence tree.  
6. Path-printer helpers (`util_preferred_cache_dir`, `util_tmp_cache_dir`, `util_fallback_cache_dir`, `util_persistent_storage_dir`) **MUST** print the path on **stdout** for `$(…)` capture (data return — not product UI). Create-and-die resolvers (`util_resolve_storage`, `util_resolve_persistent_storage`) **MUST** set `EFFECTIVE_STORAGE_DIR` / `PERSISTENT_STORAGE_DIR` in the **main process** and **MUST NOT** print the path (a stdout print would mix with product JSON). **MUST NOT** be captured with `$(…)` (that turns a fatal into a string and continues).  
7. User-visible failure about storage **MUST** use Output SSOT (`die` / structured error as mode requires).

### 2.2 Cache folder — live resolve priority (normative)

First match that is available and writable:

| Order | Condition | Path shape |
|-------|-----------|------------|
| 1 | `/dev/shm` exists and is writable | `/dev/shm/${APP_NAME}-${USERNAME}` |
| 2 | `/tmp` is writable | `/tmp/${APP_NAME}-${USERNAME}` |
| 3 | Fallback | `STORAGE_DIR` (`${XDG_CACHE_HOME}/${APP_NAME}-${USERNAME}`, env-overridable) |

**Create before return:** for the **chosen** cache tier, the resolver **MUST** `mkdir -p` the root, confirm it is writable, then print the path. If create fails or the path is not writable → **MUST** fail closed via `die`. **MUST NOT** return a path without creating it.

### 2.3 Persistence folder (normative)

1. Persistence **MUST** be **`${HOME}/.local/${APP_NAME}`** (this product: `${HOME}/.local/certbot-nginx`).  
2. **`util_persistent_storage_dir`** **MUST** print that path. **`util_resolve_persistent_storage`** **MUST** `mkdir -p` it, confirm it is writable, then print it (fail closed).  
3. **MUST NOT** use `${HOME}/.local/bin` as persistence (that is `USER_BIN`).  
4. **MUST NOT** use a Type 1 `/var/…` deposit as this CLI’s persistence folder.  
5. **MUST NOT** use `${HOME}/.local/share/${APP_NAME}` as this product’s persistence shape.  
6. **MUST NOT** store scratch/temps in the persistence folder when a cache root is available.  
7. **MUST NOT** put Let's Encrypt private keys or live cert material in the persistence folder.

### 2.4 Isolation

1. Cache paths **MUST** include **`${APP_NAME}`** and **`${USERNAME}`** (with safe defaults when unset).  
2. Persistence paths **MUST** include **`${APP_NAME}`** under the invoking user’s `${HOME}`.  
3. **MUST NOT** rewrite either resolver to a single shared world-writable directory for all users.  
4. Live product **MUST** export `TMPDIR=${EFFECTIVE_STORAGE_DIR}` so `mktemp -t` install staging inherits the isolated **cache** root. **MUST NOT** use the persistence folder as `$TMPDIR`.

### 2.5 Wire and diagnostics

| Surface | Requirement |
|---------|-------------|
| `main_certbot_nginx_app` | Resolve once early **in the main process** (not `$(util_resolve_*)` — `die` inside command substitution only exits the subshell): call `util_resolve_storage` / `util_resolve_persistent_storage` then export `EFFECTIVE_STORAGE_DIR` / `PERSISTENT_STORAGE_DIR` plus config fallback `STORAGE_DIR`; **`TMPDIR=${EFFECTIVE_STORAGE_DIR}`** |
| `show_nginx_system_diagnostics` JSON | Include `cache_preferred`, `cache_tmp`, `cache_fallback`, `persistence_storage`, live chosen cache root `effective_storage`, and `storage_dir` (no CHECKSUM) |
| `show_nginx_system_diagnostics` human | **Cache folder (preferred)** · **Cache folder (tmp)** · **Cache folder (fallback)** · **Cache folder (in use)** · **Persistence storage**. **MUST NOT** label cache lines Storage (effective)/(fallback) |

### 2.6 Implementation Notes (this project)

| Item | Live value |
|------|------------|
| **Product / binary** | `certbot-nginx` |
| **Cache resolver** | `util_resolve_storage` in `./certbot-nginx` |
| **Preferred cache** | `/dev/shm/${APP_NAME}-${USERNAME}` |
| **Tmp cache** | `/tmp/${APP_NAME}-${USERNAME}` |
| **Fallback cache** | `STORAGE_DIR` (default `${XDG_CACHE_HOME}/${APP_NAME}-${USERNAME}`) |
| **Persistence path** | `${HOME}/.local/certbot-nginx` |
| **Persistence helpers** | `util_persistent_storage_dir` (print); `util_resolve_persistent_storage` (create-before-return) |
| **Config fallback** | `: "${STORAGE_DIR:=${XDG_CACHE_HOME}/${APP_NAME}-${USERNAME}}"` |
| **Call sites** | `main_certbot_nginx_app` (cache + persistence + TMPDIR); `show_nginx_system_diagnostics` (human + JSON) |
| **Not used for** | Nginx site configs, Let's Encrypt live material, install binary (`USER_BIN` / `GLOBAL_BIN`), or other host-mutating domain trees — those are domain/OS paths (`requirement-domain-certbot-nginx.md`) |
| **Tests** | `tests/test_cli.sh` — **TP-CLI-05** about JSON `cache_preferred` / `cache_tmp` / `cache_fallback` / `persistence_storage` / `effective_storage` / `storage_dir`; human Cache folder (preferred)/(tmp)/(fallback)/(in use) + Persistence storage |

### 2.7 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution** (https://github.com/cloudgen/ciao): Multi-user / sudo / containers — never mix users’ scratch; never confuse persistence with the install bin.  
- **CIAO Principle 2 – Intentional** (https://github.com/cloudgen/ciao): Storage = cache folder **and** persistence folder; `about` says both.  
- **CIAO Principle 3 – Anti-fragile** (https://github.com/cloudgen/ciao): Missing `/dev/shm` still works via `/tmp` or cache; persistence create is fail-closed.  
- **CIAO Principle 4 / CIAO-Lite O · Principle 20** (https://github.com/cloudgen/ciao): Forbid “simplify” to shared dumps; create fail-closed.  
- **CIAO Principle 11 – Safe temps** (https://github.com/cloudgen/ciao): Scratch lives under the cache root; `$TMPDIR` is the cache, not persistence.  
- **CIAO Principle 17 – Defensive storage location** (https://github.com/cloudgen/ciao): Do not assume folders exist; resolve, create, fail loud.

### Under command line for normal user only

On Termux, Git Bash, or Windows cmd, cache and persistence stay **this login’s** folders. The program **MUST** create `${HOME}/.local/certbot-nginx` and the chosen cache root without sudo. It **MUST NOT** send those paths to `/var` and **MUST NOT** turn on admin privilege or dedicated-account privilege to create them.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- Volatile first, user cache last for **scratch**.  
- Persistence is `${HOME}/.local/certbot-nginx`, not under `bin` or `/var`.  
- Isolation before convenience.  
- Soft-`mkdir` of the effective cache or persistence root is forbidden; create is fail-closed in the resolver.  
- Data-return stdout ≠ product banners.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Remove `${APP_NAME}` / `${USERNAME}` isolation from `util_resolve_storage`.  
2. Replace either fallback chain with a single shared world-writable path.  
3. Scatter new hard-coded `/tmp/${APP_NAME}` roots outside the cache resolver.  
4. Leave the resolvers as dead code with no call sites while claiming storage is product law.  
5. Echo a tier path **without** creating it (or without fail-closed create).  
6. Bypass Output SSOT for storage failure messages.  
7. Put CHECKSUM in about storage diagnostics.  
8. Redirect Let's Encrypt private keys or live cert material into `util_resolve_storage`, the persistence folder, or other world-readable scratch roots “for convenience.”  
9. Drop persistence from this requirement or from `about`. Persistence **MUST** be `${HOME}/.local/certbot-nginx` — **MUST NOT** `${HOME}/.local/bin` or a Type 1 `/var/…` deposit.  
10. Label about cache lines **Storage (effective)** / **Storage (fallback)** instead of **Cache folder (preferred)** / **Cache folder (tmp)** / **Cache folder (fallback)** / **Cache folder (in use)**.  
11. Export `$TMPDIR` to the persistence folder.  
12. Claim this requirement is complete while it only mentions a cache folder.

**Violating this rule is a critical storage isolation regression.**

---

## 5. Definition of done (shell CLI storage)

Storage work for certbot-nginx is **not done** if any of the following fail:

1. Exactly one authoritative cache resolver (`util_resolve_storage`) sets `EFFECTIVE_STORAGE_DIR` after `mkdir -p` of that root and a writable check.  
2. Cache resolve priority matches this requirement (writable `/dev/shm` → `/tmp` → `STORAGE_DIR` fallback).  
3. Persistence helper `util_resolve_persistent_storage` creates `${HOME}/.local/certbot-nginx` (fail closed), sets `PERSISTENT_STORAGE_DIR`, and **must not** resolve to `${HOME}/.local/bin`.  
4. Cache paths include `${APP_NAME}` and `${USERNAME}` isolation; no shared world-writable single dump for all users.  
5. `main_certbot_nginx_app` sets `EFFECTIVE_STORAGE_DIR` and `PERSISTENT_STORAGE_DIR` / exports `TMPDIR` from the **cache** resolver once early, **without** `$(util_resolve_*)` so create failures `die` in the main process.  
6. `show_nginx_system_diagnostics` human + JSON expose the three cache-folder tiers, the live **in use** root, and the persistence folder, and **omit** `CHECKSUM`.  
7. User-visible storage failures use Output SSOT (`die` / structured error).  
8. Tests cover about cache + persistence fields (`tests/test_cli.sh` **TP-CLI-05**).  
9. Implementation changes cite this requirement key `requirement-shell-cli-storage`.

---

## 6. Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-05** about cache + persistence | `tests/test_cli.sh` | have |
| **TP-CLI-04** about JSON purity (peer; no CHECKSUM) | `tests/test_cli.sh` | have |
| **TP-CLI-08** `env -u HOME` does not mkdir the developer persistence folder | `tests/test_cli.sh` | have |

---

## 7. Related artifacts

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-shell-modular-function-design.md` | `util_*` ownership |
| `docs/requirements/requirement-shell-output-requirements.md` | about JSON via `output_json` |
| `docs/requirements/requirement-shell-self-management.md` | about lifecycle |
| `docs/requirements/requirement-shell-cli-interface.md` | `about` dual mention |
| `docs/requirements/requirement-domain-certbot-nginx.md` | Domain trees are not Type 0 storage |
| `./certbot-nginx` | Implementation under test |
| `tests/test_cli.sh` | Storage diagnostics tests (**TP-CLI-05**) |

---

**Last Updated**: 2026-09-06  
**Owner**: certbot-nginx project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; CIAO Principles 1, 2, 3, 4, 5, 11, 17, 19, 20 (v2.10.2) (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).

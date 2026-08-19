**file**: docs/requirements/requirement-shell-cli-zero-arguments.md  
**Requirement-ID**: `RQ-SHELL-CLI-ZERO-ARGUMENTS`  
**Status**: Active (Version 1.2.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-zero-arguments`  
**Philosophy**: CIAO / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **zero-argument (empty argv) dispatcher behavior** of the certbot-nginx POSIX `/bin/sh` Type 0 CLI.

### 1.0 Product type (template dual-model)

| Field | Value for certbot-nginx |
|-------|------------------------|
| **Empty-argv type** | **Type O — Online-install** (not Type N) |
| **Rationale** | Product advertises `curl … \| sh` one-liner install; empty argv is install-ensure, not help |

Type N (non-online-install → empty argv = help) does **not** apply to this product.

It defines what happens when the tool is invoked with **no command and no flags**, including the classic one-liner:

```sh
curl -fsSL https://raw.githubusercontent.com/Wilgat/certbot-nginx/main/certbot-nginx | /bin/sh
```

Empty argv means **install-ensure** for three detect cases:

| Case | Meaning |
|------|---------|
| **Not installed** | No managed binary at the resolved install path(s) |
| **Installed (local)** | Managed binary at the user path (`USER_BIN` / `${HOME}/.local/bin/certbot-nginx`) |
| **Installed (global)** | Managed binary at the global path (`GLOBAL_BIN` / `/usr/local/bin/certbot-nginx`) |

**Scope:** Empty-argv routing, detect cases (global / local / absent), messages, force boundary, exit status, interaction with TTY / quiet / json.  
**Out of scope (own requirements):** Full command catalog (`requirement-shell-cli-interface.md`); download/checksum detail (`requirement-shell-automatic-checksum.md`); full self-update/uninstall lifecycle (`requirement-shell-self-management.md`); output function catalog (`requirement-shell-output-requirements.md`); general idempotency matrix beyond empty-argv rows (`requirement-shell-idempotency.md`).

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Definitions (portable + project)

| Term | Definition for certbot-nginx |
|------|----------------------------|
| **Type O** | Online-install empty-argv product type: empty argv = install-ensure (this product). |
| **Type N** | Non-online-install empty-argv type: empty argv = help — **out of scope** for certbot-nginx. |
| **Empty argv / zero-arg** | `$# -eq 0` at entry to `main_certbot_nginx_app` (no command tokens; classic `curl \| sh` with no trailing args). |
| **Install-ensure** | Converge to “managed `certbot-nginx` binary present”; either perform install or success no-op. |
| **Not installed** | `is_installed` returns false (`get_installed_version` → `not installed`). |
| **Installed (local)** | Executable at `${USER_BIN}/certbot-nginx` (default `USER_BIN=${HOME}/.local/bin`) observed by install-detect SSOT. |
| **Installed (global)** | Executable at `${GLOBAL_BIN}/certbot-nginx` (default `GLOBAL_BIN=/usr/local/bin`) observed by install-detect SSOT. |
| **Force / reinstall** | `FORCE_REINSTALL=1` from `--force` (and related force wiring in `main_certbot_nginx_app`). Required only for deliberate replace, not for ensure. |

### 2.2 Single meaning of empty argv

1. When **argv is empty**, `main_certbot_nginx_app` **MUST** run **install-ensure** — **MUST NOT** route to `show_certbot_nginx_help` / default `COMMAND=help`.  
2. Explicit `certbot-nginx help` remains the only full-usage path for help text.  
3. Bootstrap **MUST** always call `main_certbot_nginx_app "$@"` so pipe one-liners reach this contract (no `${0##*/}` product-name gate).  
4. Empty argv **MUST NOT** require the user to pass `install` or `install --force` merely because a previous ensure already succeeded.

### 2.2.1 Specializee contract (bootstrap origin → specialized B)

When this product is used as **bootstrap origin A** for a specialized product **B** (A→B only; never reverse-copy):

| Rule | MUST | MUST NOT |
|------|------|----------|
| Empty argv on B | Keep **Type O install-ensure** (or document a product-type change with authorized REQ) | Hijack empty argv for domain full-setup / host mutation |
| Domain setup verb | Use an explicit command (e.g. `run`, `setup`, domain verb catalog) | Treat bare `curl \| sh` / empty argv as host domain install |
| Tests | Isolate `HOME`, `USER_BIN`, and **`GLOBAL_BIN`** so host `/usr/local/bin/${APP_NAME}` does not shadow lifecycle CI | Assume empty `HOME` alone hides a real global install |

**Rationale:** Specializees that rebind empty argv to interactive host setup break the online-install contract and confuse install-ensure with domain ops. Host-mutating domain work belongs under explicit verbs with privilege gates (see CLI interface specializee contract).

### 2.3 Normative case matrix

| Case | Detect condition (project) | Empty argv, `FORCE_REINSTALL=0` | Empty argv / install with force |
|------|----------------------------|--------------------------------|---------------------------------|
| **A. Not installed** | `is_installed` false | Install into privilege-correct path (§2.4) | Same first-time install |
| **B. Installed — local** | User binary present via detect SSOT | Success no-op: already installed; no re-download; **no help** | `perform_self_install_v2` re-download/replace (user path when non-root) |
| **C. Installed — global** | Global binary present via detect SSOT | Success no-op: already installed; no re-download; **no help** | Re-download/replace (global path when root / global binary policy) |

**Already-installed rules (Cases B and C, force off):**

1. Exit status **MUST** be `0`.  
2. Human mode **MUST** use `success` with an **already installed** message (Type O no-op path).  
3. Human mode **MAY** add `info` tips that `--force` / `self-update` are for **deliberate** reinstall or upgrade — **MUST NOT** imply force is required for a normal one-liner re-run.  
4. JSON mode **MUST** use structured success (`output_json` success type) with already-installed message — **MUST NOT** emit help JSON.  
5. Detect **MUST** treat either global or local managed binary as installed when that is how `is_installed` / `get_installed_version` resolve paths (project SSOT today prefers global when executable there, else user path).

### 2.4 Case A — not installed (modes)

| Mode | Required empty-argv behavior |
|------|------------------------------|
| **Interactive** (TTY stdin+stdout, not quiet/json) | `maybe_install_v2`: note + `prompt_yes_no`; yes → `perform_self_install_v2`; no → skip without help dump |
| **Non-interactive** (non-TTY / `curl \| sh`) | Auto-install message + `perform_self_install_v2` (via `maybe_install_v2` non-TTY branch) |
| **Quiet or JSON** | `perform_self_install_v2` directly (no prompt) |
| **Failure** (network, checksum, I/O) | Non-zero exit; no fake success; no help-only output |

**Placement privilege:**

| Invoker | Target |
|---------|--------|
| root (`id -u` 0), e.g. `curl … \| sudo sh` | `${GLOBAL_BIN}/certbot-nginx` → `/usr/local/bin/certbot-nginx` |
| non-root | `${USER_BIN}/certbot-nginx` → `${HOME}/.local/bin/certbot-nginx` |

### 2.5 Equivalence to explicit `install`

| Invocation | Contract |
|------------|----------|
| Empty argv | Same ensure semantics as `install` for Cases A/B/C |
| `install` | Explicit ensure; same detect / no-op / force |
| `install --force` | Deliberate reinstall |
| `help` | Usage only — **not** empty-argv default |

### 2.6 Forbidden empty-argv outcomes

1. Dump full help when Case B or C applies.  
2. Silent success when Case A should install (or when Case B/C should acknowledge already installed).  
3. Require `--force` solely because detect says installed.  
4. Blind re-download every empty-argv run without force.  
5. Basename-gate main so `curl \| sh` never hits the empty-argv branch.  
6. Detect only one of global/local incorrectly so a present local install is treated as Case A (or the reverse) contrary to `is_installed` SSOT.

### 2.7 Implementation Notes (this project)

| Item | Value for certbot-nginx |
|------|------------------------|
| **Empty-argv type** | **Type O — Online-install** (install-ensure; not Type N help-default) |
| **Product / binary** | `certbot-nginx` (`APP_NAME`) |
| **Ship unit** | Repo root `./certbot-nginx` |
| **Dispatcher** | `main_certbot_nginx_app` — empty-argv block **before** flag/command parse default help |
| **Install ensure** | `perform_self_install_v2` (quiet/json); already-installed no-op in the empty-argv block |
| **Friendly first install** | `maybe_install_v2` (TTY confirm / non-TTY auto) when not installed and not quiet/json |
| **Detect SSOT** | `is_installed` ← `get_installed_version` |
| **Global path** | `GLOBAL_BIN` default `/usr/local/bin` |
| **Local path** | `USER_BIN` default `${HOME}/.local/bin` |
| **Force wiring** | `--force` → `FORCE_REINSTALL=1` in `main_certbot_nginx_app` |
| **Output SSOT** | `success` / `info` / `output_json` / errors via `die` |
| **Channel** | `SCRIPT_URL` (compose from `REPO_USER` / `REPO_NAME` / `APP_NAME`) for download path inside install |
| **Tests** | `tests/test_cli.sh` (Case A failure when not installed); `tests/test_install_lifecycle.sh` (Case B local + Case C global already-installed → not help) |

#### Dispatcher algorithm (normative sketch)

```text
main_certbot_nginx_app:
  if [ $# -eq 0 ]; then
    if is_installed and not FORCE_REINSTALL:
      success no-op (hint: sudo ${APP_NAME} setup); exit 0
    if JSON or QUIET:
      perform_self_install_v2; exit $?
    else
      maybe_install_v2     # Case A (TTY prompt / non-TTY auto)
      exit $?
    fi
  fi
  # else parse flags/commands
```

#### Message contract (already installed, human)

- Success: already-installed Type O no-op (via `success`)  
- Optional info: `sudo ${APP_NAME} setup` for domain host work  
- **MUST NOT** print the full `show_certbot_nginx_help` usage body on this path

### 2.8 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution** (https://github.com/cloudgen/ciao): One-liner re-runs must not look like broken install or force unnecessary reinstall.  
- **CIAO Principle 2 – Intentional** (https://github.com/cloudgen/ciao): Empty argv has one meaning for not-installed, local, and global.  
- **CIAO Principle 3 – Anti-fragile** (https://github.com/cloudgen/ciao): Dual install paths + `curl \| sh` + TTY.  
- **CIAO Principle 6 – Single Point of Entry** (https://github.com/cloudgen/ciao): `main_certbot_nginx_app` owns empty-argv before help default.  
- **CIAO Principle 16 – Interactive vs Non-Interactive** (https://github.com/cloudgen/ciao): Case A auto under pipe; optional TTY confirm.  
- **CIAO Principle 4 (O) / Principle 20 – Over-protect / Protect Against AI & Human Modification** (https://github.com/cloudgen/ciao): Protection Rule against help-fallback regression.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Real failures non-zero; healthy re-runs success with clear text.  
- **Intentional:** Help is never the empty-argv default for this install CLI.  
- **Anti-fragile:** Global and local detect; idempotent second one-liner.  
- **Over-protect:** Do not “simplify” empty-argv back to `COMMAND:=help` after first install.  
- **SSOT:** `is_installed` / `perform_self_install_v2` / `maybe_install_v2` / `success` / `info`.  
- **Idempotent ensure:** Case B/C force off → already installed, exit 0.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Route empty argv to `show_certbot_nginx_help` when Case B or C applies (or when Case A should install).  
2. Require `--force` for a healthy already-installed empty-argv re-run (local or global).  
3. Handle only Case A and leave B/C as accidental help fallthrough.  
4. Break dual-path detect so local or global installs are misclassified.  
5. Blindly reinstall on every empty-argv run without `FORCE_REINSTALL`.  
6. Exit 0 with no install and no already-installed acknowledgment when detect says installed.  
7. Reintroduce a basename-only gate that skips `main_certbot_nginx_app` under `curl \| sh`.  
8. Bypass `out_*` for empty-argv user messages.  
9. Contradict this file in peer requirements by documenting “already installed → help” as normative empty-argv behavior.

**Violating this rule is a critical zero-arg / online-install regression.**

---

## 5. Definition of done

This requirement is satisfied when all of the following hold:

1. Empty argv + not installed → Case A install path (TTY may confirm; non-TTY / quiet / json auto).  
2. Empty argv + local install present + force off → already-installed success; not help; no re-download.  
3. Empty argv + global install present + force off → already-installed success; not help; no re-download.  
4. Empty argv + install failure → non-zero exit.  
5. `--force` only for deliberate reinstall; not required for ensure.  
6. `help` works when invoked explicitly.  
7. Tests cover Case A failure (not installed, bad channel) and already-installed not-help for local (Case B) and global (Case C).  
8. Changes cite `requirement-shell-cli-zero-arguments`.

---

## 6. Related artifacts

| Artifact | Role |
|----------|------|
| `docs/requirements/requirement-shell-cli-interface.md` | Full command surface; empty-argv row must match this SSOT |
| `docs/requirements/requirement-shell-idempotency.md` | Ensure re-run / force boundary |
| `docs/requirements/requirement-shell-interactive-vs-noninteractive.md` | TTY vs pipe for Case A |
| `docs/requirements/requirement-shell-self-management.md` | self-update / uninstall (not empty-argv default) |
| `docs/requirements/requirement-shell-output-requirements.md` | out_* / JSON purity |
| `docs/requirements/requirement-shell-automatic-checksum.md` | Integrity on install download path |
| Repo root `./certbot-nginx` | Implementation (`main_certbot_nginx_app`, `perform_self_install_v2`, `maybe_install_v2`) |
| `tests/test_cli.sh`, `tests/test_install_lifecycle.sh` | Regression coverage |

---

## 7. Revision history

| Date | Change | Author / agent |
|------|--------|----------------|
| 2026-07-14 | Initial Active v1.0.0: empty argv = install-ensure for not-installed / local / global; forbid help fallthrough | Grok (owner request) |
| 2026-07-14 | v1.1.0: Classify product as Type O (online-install) under dual-type empty-argv template model | Grok |
| 2026-08-11 | v1.2.0: Specializee contract — empty argv stays Type O; domain setup uses explicit verbs; test GLOBAL_BIN isolation | Grok (gitlab-nginx specialize reflection) |

---

**Last Updated**: 2026-07-19  
**Owner**: certbot-nginx project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; CIAO Principles 1, 2, 3, 6, 16, 4, 20 (v2.10.2) (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).


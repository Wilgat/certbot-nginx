# Product review: certbot-nginx (full product + requirement coverage)

**Date:** 2026-08-12  
**Reviewer:** multi-agent council (Review + Security + Implement)  
**Product:** certbot-nginx `VERSION=1.16.0`  
**Ship unit:** `./certbot-nginx`  
**Scope:** Ship unit, Type 0 lifecycle, domain surface, requirement sufficiency, bootstrap specialize residue  
**Method:** disk read + requirement sufficient-check + suite authoring; `./tests/run.sh` executed  
**Baseline:** `./tests/run.sh` → **PASS=100 FAIL=0 SKIP=1** (RESULT: OK)

## Summary

certbot-nginx is a mature specialized product (online self-managed CLI + Nginx/Certbot domain) specialized from bootstrap **selfmanaged**. Domain law and Type 0 ownership exist after the specialize pass. This review found **critical Type 0 integrity/JSON/privilege bugs** (checksum verify, `output_json` arity, `FORCE_GLOBAL` default, uninstall fail-closed, non-interactive setup without root, install exit masking, dispatcher always `exit 0`). Same-day fixes landed; Core suite is green. Remaining open gaps: REQ honesty residue, README usage-table drift, downgrade gate, privileged full-setup integration tests.

## Strengths

| Area | Notes |
|------|--------|
| Domain design | Certbot standalone sequence, nginx-adm least privilege, Cloudflare origin default, dated backups |
| Specialize direction | Bootstrap A (`selfmanaged`) frozen; domain SSOT + bootstrap-chain registered |
| Type O restore | Empty argv is install-ensure; domain uses explicit `setup`/`run` |
| Channel identity | `APP_NAME` / `REPO_*` / README one-liners align with Wilgat/certbot-nginx |
| Diagnostics | `about` includes nginx platform fields; `domains`/`email` read-only tools |

## Findings

### CNX-INST-01 — Severity: P0 (critical) — **fixed**
- **Area:** install integrity  
- **Status:** fixed  
- **Location:** `perform_self_install_v2` automatic companion path  
- **Description:** Companion verify used `sha256sum -c` against bare-hex / wrong stdin usage, so valid bare `.sha256` always failed.  
- **Impact:** Online install with companion present aborted (false mismatch).  
- **Suggestion:** Compare first field of sidecar to `sha256sum` of download (implemented).  
- **Cross-ref:** `requirement-shell-automatic-checksum`

### CNX-OUT-01 — Severity: P0 (critical) — **fixed**
- **Area:** JSON output  
- **Status:** fixed  
- **Location:** `version_check`, several `output_json "success" "message" ...` call sites  
- **Description:** Second argument treated as `message`, so key/value pairs shifted; machine clients saw garbage keys.  
- **Impact:** Broken automation contracts for version-check / install / uninstall JSON.  
- **Suggestion:** Pass empty message or real message string only (implemented).  
- **Cross-ref:** `requirement-shell-output-requirements`

### CNX-INST-02 — Severity: P1 (high) — **fixed**
- **Area:** install path defaults  
- **Status:** fixed  
- **Location:** Config `FORCE_GLOBAL` default  
- **Description:** Default `FORCE_GLOBAL=1` made non-root uninstall path prefer global only and confused install detection.  
- **Impact:** User installs could not be uninstalled reliably; CI isolation failed.  
- **Suggestion:** Default `FORCE_GLOBAL=0` (implemented).  

### CNX-SM-01 — Severity: P1 (high) — **fixed**
- **Area:** self-uninstall  
- **Status:** fixed  
- **Location:** `self_uninstall`  
- **Description:** JSON/non-interactive path removed without `--force` (not fail-closed).  
- **Impact:** Unsafe automation remove; diverged from Type 0 self-management law.  
- **Suggestion:** `confirm_required` without `--force` (implemented).  
- **Cross-ref:** `requirement-shell-self-management`

### CNX-SEC-01 — Severity: P0 (critical) — **fixed**
- **Area:** domain privilege  
- **Status:** fixed  
- **Location:** `run_non_interactive_setup` / `setup` dispatch  
- **Description:** Non-interactive `setup`/`run` did not call `check_root` and could mutate host nginx configs as a normal user (partial writes).  
- **Impact:** Privilege/host-safety break; Core tests accidentally mutated this host before the gate was fixed.  
- **Suggestion:** `check_root` on all setup paths (implemented).  
- **Cross-ref:** `requirement-domain-certbot-nginx`

### CNX-INST-03 — Severity: P1 (high) — **fixed**
- **Area:** install exit codes  
- **Status:** fixed  
- **Location:** `maybe_install_v2` (`exit 0` after failed install); dispatcher `exit 0` after failing self-uninstall/self-update  
- **Impact:** CI and automation saw success after failures.  
- **Suggestion:** Propagate `exit $?` (implemented).  

### CNX-INST-04 — Severity: P1 (high) — **fixed**
- **Area:** channel override  
- **Status:** fixed  
- **Location:** Config `SCRIPT_URL` hard-assign  
- **Description:** Env `SCRIPT_URL` could not override product channel (blocked isolated tests and mirrors).  
- **Suggestion:** `: "${SCRIPT_URL:=…}"` composition (implemented).  

### CNX-REQ-01 — Severity: P1 (high) — **open**
- **Area:** requirements honesty  
- **Status:** open  
- **Location:** `requirement-shell-cli-storage`, automatic-checksum / output Implementation Notes  
- **Description:** Active storage law DoD requires `util_resolve_storage` / about storage fields not present in ship unit; several REQs still claim bootstrap `inst_*`/`out_*` Implemented.  
- **Impact:** False sufficiency / agents implement wrong names.  
- **Suggestion:** Retarget notes to disk-truth handlers or mark storage N/A/Gap for this product.  
- **Cross-ref:** prior sufficient-check verdict

### CNX-SM-02 — Severity: P1 (high) — **open**
- **Area:** self-update  
- **Status:** open  
- **Location:** `self_update_v2`  
- **Description:** No semver older-than-local refuse; any remote version difference reinstalls.  
- **Impact:** Silent downgrade possible via channel.  
- **Suggestion:** Add `ver_gt` refuse without `--force` (Partial already in self-management notes).  

### CNX-DOC-01 — Severity: P1 (high) — **fixed**
- **Area:** product docs  
- **Status:** fixed  
- **Location:** `README.md` usage table  
- **Description:** Documented bare `sudo certbot-nginx` as full interactive setup; Quick Start correctly uses `setup`.  
- **Impact:** Operator confusion after Type O specialize.  
- **Suggestion:** Change table to `sudo certbot-nginx setup` (implemented).  

### CNX-DOC-02 — Severity: P2 (medium) — **open**
- **Area:** operator strings  
- **Status:** open  
- **Location:** domains/email JSON empty hints; internal msgs  
- **Description:** “Run: `sudo ${APP_NAME}`” omits `setup`.  
- **Impact:** Users re-hit Type O no-op.  
- **Suggestion:** Point to `setup`.  

### CNX-TEST-01 — Severity: P2 (medium) — **fixed** (baseline suite)
- **Area:** tests  
- **Status:** fixed  
- **Location:** `tests/`  
- **Description:** No product suite after specialize (A’s suite does not prove B).  
- **Impact:** Regressions uncaught.  
- **Suggestion:** Port Type 0 + domain smoke suite (implemented under `tests/`).  
- **Evidence:** `./tests/run.sh` PASS=100 FAIL=0 SKIP=1  

### CNX-DOM-01 — Severity: P2 (medium) — **deferred**
- **Area:** domain integration  
- **Status:** deferred  
- **Location:** `setup` / certbot / nginx host path  
- **Description:** Core CI does not run full privileged domain setup.  
- **Impact:** Host sequence regressions need manual/privileged tests.  
- **Suggestion:** Optional integration job with disposable VM; keep Core suite non-destructive.  

## Non-findings (explicitly OK)

| Check | Result |
|-------|--------|
| Bootstrap reverse-copy on A | Local `./selfmanaged` frozen vs peer |
| Domain SSOT registered | `requirement-domain-certbot-nginx` present |
| Help ↔ dispatcher | Domain and Type 0 verbs listed and routed |
| CHECKSUM not on help | Pass |
| Identity channel SSOT | Wilgat/certbot-nginx aligned |

## Priority remediation order

1. ~~P0 checksum, JSON arity, FORCE_GLOBAL, uninstall fail-closed, non-root setup, exit masking, SCRIPT_URL override~~ **done this review**  
2. **P1** REQ honesty retarget (storage / Implemented tables)  
3. **P1** README usage table + operator `setup` strings  
4. **P1** self-update downgrade gate (`ver_gt`)  
5. **P2** privileged domain integration tests (optional)

## Related

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Product law inventory |
| `docs/reviews/test-plan.md` | TP map |
| `docs/reviews/requirement-test-matrix.md` | RTM |
| `tests/run.sh` | Suite entry |
| `docs/checklists/2026-08-12-checklist-bootstrap-specialize-product-certbot-nginx.md` | Specialize Pass |

**Written by:** multi-agent council  
**Review status:** Partial fixed (P0 closed; Core suite green; open P1 law/docs/downgrade)

# Report: 1.16.4 cache + persistence — certbot-nginx 1.16.4

**Date:** 2026-09-06
**Mode:** local change review + fix
**Status:** closed in this change

## Summary

Release 1.16.4 adds a persistence folder at `${HOME}/.local/certbot-nginx` and relabels `about` cache diagnostics. Review found three bugs (about fallback vs `/tmp` resolve tier; deleted `docs/reviews/` maps; `env -u HOME` mkdir on the developer home). This change restores the reviews tree, prints all three cache tiers plus the live **in use** root, isolates HOME-unset tests with a stub `getent`, and adds §1.1 Human-facing on every REQ edited here.

## Issues

### Issue 1 -- Severity: bug
- File: docs/requirements/requirement-shell-cli-storage.md:60
- Description: Cache law, about printers, and the live resolver disagreed on “fallback” vs `/tmp`.
- Suggestion: Print preferred, tmp, fallback, and in-use (human + JSON). Point fallback at `STORAGE_DIR`.
- Lesson: L-STORAGE-01
- Test: TP-CLI-05
- Status: closed

### Issue 2 -- Severity: bug
- File: docs/.gitignore:1
- Description: Nested gitignore dropped `!reviews/` and deleted DTV maps.
- Suggestion: Restore git-tracked `docs/reviews/` and TP-CLI-05 rows.
- Lesson: L-REVIEWS-01
- Test: TP-CLI-05 map row
- Status: closed

### Issue 3 -- Severity: bug
- File: tests/test_cli.sh:122
- Description: `env -u HOME` reconstructed HOME via `getent` and mkdir’d developer persistence.
- Suggestion: Stub `getent` to the isolated HOME; assert host persistence not created.
- Lesson: L-HOME-UNSET-01
- Test: TP-CLI-08
- Status: closed

### Issue 4 -- Severity: bug
- File: certbot-nginx:4185
- Description: `PERSISTENT_STORAGE_DIR=$(util_resolve_persistent_storage)` meant `die` only exited the subshell; about continued with exit 0 and stuffed the error JSON into `persistence_storage`.
- Suggestion: Call resolvers in the main process; they set the globals and `die` without stdout capture.
- Lesson: L-DIE-SUBSHELL-01
- Test: TP-CLI-05 fail-closed mkdir
- Status: closed

## Checklist (this change)

- CL-PLAN-AND-REQUIREMENTS: filled `docs/checklists/2026-09-06-checklist-plan-and-requirements-storage.md` (local; gitignored harness tree)
- CL-SHELL-CLI-TEST: filled `docs/checklists/2026-09-06-checklist-shell-cli-test-storage.md`
- CL-PRECOMMIT-CHECK: run at commit gate (skill-commit-check)
- Human-readable-law: §1.1 added on edited REQs; storage has **Under command line for normal user only**
- Reviews tree: restored and updated

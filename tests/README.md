# Tests (certbot-nginx)

POSIX `/bin/sh` CI suite for the Type 0 + domain ship unit `./certbot-nginx`.

## Run locally

```sh
./tests/run.sh
```

Requires: `sh`, `curl`, `python3` (local HTTP channel), `sha256sum`, `grep`.

## What is covered

| Suite | File | Focus |
|-------|------|--------|
| CLI surface | `test_cli.sh` | `sh -n`, companion digest, version/help/about (cache folder + persistence folder), domain help rows, unknown, quiet, no CHECKSUM, `env -u HOME`, zero-arg fail, self-uninstall fail-closed |
| Install lifecycle | `test_install_lifecycle.sh` | Isolated HOME/USER_BIN/GLOBAL_BIN, local channel install, Type O empty argv, version-check, self-update latest, checksum transparency, pin match/mismatch, uninstall refuse/force |
| Domain smoke | `test_domain_surface.sh` | Non-destructive: setup/run fail-closed without root, domains/email diagnostics, nginx-conf fail-closed, empty argv ≠ domain setup |

**Not covered (by design):** full `setup` host mutation (packages, certbot, live nginx). That requires privileged integration tests outside Core CI.

## Isolation

- Temp `HOME` / `USER_BIN` / `GLOBAL_BIN` — never installs into the developer host tree.
- Install channel is `127.0.0.1` only for Core lifecycle cases.
- Companion digest is regenerated from served bytes on the local channel.

## Maps

- Product TP map: `docs/reviews/test-plan.md`
- RTM: `docs/reviews/requirement-test-matrix.md`
- Product review: `docs/reviews/2026-08-12-product-review.md`

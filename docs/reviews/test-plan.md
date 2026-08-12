# Review-driven test plan (certbot-nginx)

Maps **portable TP families** to product-root `tests/`.  
Status: **have** = covered by suite · **todo** = planned · **n/a** = not applicable · **optional** = gated · **skip** = known product Partial.

Runner: `./tests/run.sh`  
**RTM:** `docs/reviews/requirement-test-matrix.md`

| Family | Suite file |
|--------|------------|
| **TP-CLI** | `tests/test_cli.sh` |
| **TP-LC** | `tests/test_install_lifecycle.sh` |
| **TP-CSUM** | CLI + lifecycle |
| **TP-U** | CLI (partial) |
| **TP-CNX** | `tests/test_domain_surface.sh` (domain smoke) |

---

## TP-CLI — CLI surface

| TP-ID | Intent | Status | Evidence |
|-------|--------|--------|----------|
| **TP-CLI-01** | `sh -n` + companion digest | **have** | `test_cli.sh` |
| **TP-CLI-02** | version human + JSON | **have** | `test_cli.sh` |
| **TP-CLI-03** | help Type 0 + domain; no CHECKSUM; no foreign DNA | **have** | `test_cli.sh` |
| **TP-CLI-04** | help/about JSON purity | **have** | `test_cli.sh` |
| **TP-CLI-05** | shell storage about fields | **n/a** | product has no util_resolve_storage (CNX-REQ-01) |
| **TP-CLI-06** | unknown command + JSON error | **have** | `test_cli.sh` |
| **TP-CLI-07** | quiet / `-q` | **have** | `test_cli.sh` |
| **TP-CLI-08** | `env -u HOME` | **have** | `test_cli.sh` |
| **TP-CLI-09** | zero-arg bad channel loud fail | **have** | `test_cli.sh` |
| **TP-CLI-11** | self-uninstall refuse JSON | **have** | `test_cli.sh` |

---

## TP-LC — Install lifecycle

| TP-ID | Intent | Status | Evidence |
|-------|--------|--------|----------|
| **TP-LC-01** | zero-arg ensure when installed local/global | **have** | lifecycle |
| **TP-LC-04** | about + version-check JSON keys | **have** | lifecycle |
| **TP-LC-05** | self-update already-latest | **have** | lifecycle |
| **TP-LC-06** | force reinstall companion transparency | **have** | with TP-CSUM-02 |
| **TP-LC-07** | uninstall refuse / force | **have** | lifecycle |
| **TP-LC-08** | downgrade refuse / force | **skip** | CNX-SM-02 Partial |
| **TP-LC-09** | zero-arg fail loud | **have** | CLI |
| **TP-LC-10** | idempotent re-install | **have** | lifecycle |
| **TP-LC-12** | explicit `install --json` | **have** | lifecycle |

---

## TP-CSUM — Checksum

| TP-ID | Intent | Status | Evidence |
|-------|--------|--------|----------|
| **TP-CSUM-01** | companion matches ship unit | **have** | CLI |
| **TP-CSUM-02** | human force reinstall transparency | **have** | lifecycle |
| **TP-CSUM-03** | pin mismatch aborts | **have** | lifecycle |
| **TP-CSUM-04** | pin match installs | **have** | lifecycle |
| **TP-CSUM-05** | help/about hide CHECKSUM | **have** | CLI |

---

## TP-U — set -u (partial)

| TP-ID | Intent | Status | Evidence |
|-------|--------|--------|----------|
| **TP-U-01** | HOME unset | **have** | TP-CLI-08 |
| **TP-U-02** | Defaults on zero-arg fail path | **have** | TP-CLI-09 |

---

## TP-CNX — Domain (certbot-nginx)

| TP-ID | Intent | Status | Evidence |
|-------|--------|--------|----------|
| **TP-CNX-01** | about nginx platform fields | **have** | CLI about JSON |
| **TP-CNX-02** / **TP-CNX-PRIV-01** | setup/run fail-closed without privilege (host-mutating) | **have** | domain suite; CL-HOST-MUTATING-DOMAIN |
| **TP-CNX-03** | domains/email diagnostics | **have** | domain suite |
| **TP-CNX-04** | nginx-conf fail-closed | **have** | domain suite |
| **TP-CNX-05** | empty argv ≠ domain setup | **have** | domain suite |
| **TP-CNX-10** | full interactive setup integration | **todo** | privileged; deferred CNX-DOM-01 |

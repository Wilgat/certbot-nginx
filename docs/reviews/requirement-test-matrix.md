# Requirement → test matrix (certbot-nginx)

**Updated:** 2026-08-12  
**Runner:** `./tests/run.sh`  
**Map:** `docs/reviews/test-plan.md`

| Requirement | TP families | Coverage notes |
|-------------|-------------|----------------|
| `requirement-class-software-dev` | suite umbrella | Residual; tests prove ship unit class stack |
| `requirement-bootstrap-chain` | (process) | No TP; direction reviewed in product review |
| `requirement-shell-cli-interface` | **TP-CLI**, **TP-LC** | help/version/unknown/flags |
| `requirement-shell-cli-zero-arguments` | **TP-LC-01**, **TP-CLI-09** | Type O empty argv |
| `requirement-shell-self-management` | **TP-LC**, **TP-CLI-11** | version-check, update, uninstall; downgrade **Partial** |
| `requirement-shell-automatic-checksum` | **TP-CSUM** | companion + pin + transparency |
| `requirement-shell-output-requirements` | **TP-CLI-02/04/06/07** | JSON types `success`/`error`/`version`/`about` |
| `requirement-shell-interactive-vs-noninteractive` | **TP-CLI-11**, **TP-LC-07** | confirm_required |
| `requirement-shell-idempotency` | **TP-LC-10**, **TP-LC-05** | re-install; already-latest |
| `requirement-shell-modular-function-design` | indirect | Behavior via commands |
| `requirement-shell-cli-storage` | **TP-CLI-05** | about JSON `effective_storage` / `storage_dir` |
| `requirement-domain-certbot-nginx` | **TP-CNX** | Non-destructive smoke; full setup **todo** |
| `requirement-nginx-conf` / **`RQ-NGINX-CONF`** | **TP-CNX** (partial) | Conf structure law registered; generator body asserts still host/manual — no dedicated conf-only TP yet |

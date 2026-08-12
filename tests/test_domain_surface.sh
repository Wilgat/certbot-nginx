# =============================================================================
# tests/test_domain_surface.sh — domain help/dispatch smoke (no host mutation)
# Maps: TP-CNX-*  (certbot-nginx domain)
# Primary law: requirement-domain-certbot-nginx
# Does NOT run setup (would mutate host packages/nginx/certs).
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_domain_surface() {
    t_header "Domain surface smoke (TP-CNX) — non-destructive"

    require_cmd sh

    # TP-CNX-02 domain verbs routed (not unknown)
    # setup without root MUST fail closed (privilege) — never mutate host as non-root
    _combo=$(sh "${SCRIPT}" setup 2>&1)
    _ec=$?
    if [ "$_ec" -ne 0 ]; then
        t_pass "TP-CNX-02 setup without privilege exits non-zero"
    else
        t_fail "TP-CNX-02 setup without privilege unexpectedly exit 0"
    fi
    assert_contains "TP-CNX-02 setup requires root" "$_combo" "root"
    assert_not_contains "TP-CNX-02 setup is not unknown argument" "$_combo" "Unknown argument"

    # run alias same family
    _combo=$(sh "${SCRIPT}" run 2>&1)
    _ec=$?
    if [ "$_ec" -ne 0 ]; then
        t_pass "TP-CNX-02 run alias exits non-zero without privilege"
    else
        t_fail "TP-CNX-02 run unexpectedly exit 0"
    fi
    assert_contains "TP-CNX-02 run requires root" "$_combo" "root"

    # TP-CNX-03 domains/email diagnostics (read-only; may warn empty)
    _out=$(sh "${SCRIPT}" domains 2>&1)
    _ec=$?
    # exit 0 with empty or configured is ok
    assert_eq "TP-CNX-03 domains exit 0" 0 "$_ec"
    assert_not_contains "TP-CNX-03 domains not unknown" "$_out" "Unknown argument"

    _out=$(sh "${SCRIPT}" --json domains 2>&1)
    _ec=$?
    assert_eq "TP-CNX-03 domains --json exit 0" 0 "$_ec"
    assert_contains "TP-CNX-03 domains --json has type" "$_out" '"type":'

    _out=$(sh "${SCRIPT}" email 2>&1)
    _ec=$?
    assert_eq "TP-CNX-03 email exit 0" 0 "$_ec"

    _out=$(sh "${SCRIPT}" --json email 2>&1)
    _ec=$?
    assert_eq "TP-CNX-03 email --json exit 0" 0 "$_ec"
    assert_contains "TP-CNX-03 email --json has type" "$_out" '"type":'

    # TP-CNX-04 nginx-conf without root / without domains fail closed
    _err=$(sh "${SCRIPT}" nginx-conf 2>&1 >/dev/null)
    _ec=$?
    if [ "$_ec" -ne 0 ]; then
        t_pass "TP-CNX-04 nginx-conf without privilege/domains fails closed"
    else
        t_fail "TP-CNX-04 nginx-conf unexpectedly exit 0"
    fi
    assert_not_contains "TP-CNX-04 not unknown" "$_err" "Unknown argument"

    # TP-CNX-05 empty argv is not domain setup
    ci_isolated_env
    # place stub install so Type O no-op path runs
    cp "${SCRIPT}" "${CI_USER_BIN}/${APP_NAME}"
    chmod +x "${CI_USER_BIN}/${APP_NAME}"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" FORCE_GLOBAL=0 \
        sh "${SCRIPT}" </dev/null 2>/dev/null
    )
    assert_contains "TP-CNX-05 empty argv Type O no-op" "$_out" "already installed"
    assert_contains "TP-CNX-05 hints setup for domain" "$_out" "setup"
    ci_cleanup_env
}

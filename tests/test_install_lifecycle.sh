# =============================================================================
# tests/test_install_lifecycle.sh — Type O install / lifecycle (local channel)
# Maps: TP-LC-*, TP-CSUM-02/03/04
# Primary law: requirement-shell-self-management, zero-arguments, automatic-checksum
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_install_lifecycle() {
    t_header "Install lifecycle (TP-LC / local channel)"

    require_cmd curl
    require_cmd python3
    require_cmd sha256sum

    ci_isolated_env
    if ! ci_start_channel; then
        ci_cleanup_env
        return 1
    fi

    _bin="${CI_USER_BIN}/${APP_NAME}"
    _errf="${CI_HOME}/lc-err.txt"

    # TP-LC-12 explicit install --json
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" FORCE_GLOBAL=0 \
        SCRIPT_URL="${CI_SCRIPT_URL}" \
        sh "${SCRIPT}" --json install 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "TP-LC-12 install --json exit 0" 0 "$_ec"
    assert_contains "TP-LC-12 install --json success type" "$_out" '"type":"success"'
    assert_contains "TP-LC-12 install --json path" "$_out" "${_bin}"
    assert_file_exists "TP-LC-12 installed binary exists" "${_bin}"

    # TP-LC-10 idempotent re-install
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" FORCE_GLOBAL=0 \
        SCRIPT_URL="${CI_SCRIPT_URL}" \
        sh "${SCRIPT}" --json install 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-LC-10 re-install --json exit 0" 0 "$_ec"
    assert_contains "TP-LC-10 already installed message" "$_out" "already installed"

    # TP-LC-01 zero-arg when installed local = Type O no-op, not help / not setup
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" FORCE_GLOBAL=0 \
        SCRIPT_URL="${CI_SCRIPT_URL}" \
        sh "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-LC-01 zero-arg installed (local) exit 0" 0 "$_ec"
    assert_contains "TP-LC-01 already installed" "$_out" "already installed"
    assert_not_contains "TP-LC-01 must not dump Usage help" "$_out" "Usage:"
    assert_not_contains "TP-LC-01 must not run domain setup text as sole path" "$_out" "Let's Encrypt registration"

    # Case C global stub
    mkdir -p "${CI_GLOBAL_BIN}"
    cp "${SCRIPT}" "${CI_GLOBAL_BIN}/${APP_NAME}"
    chmod +x "${CI_GLOBAL_BIN}/${APP_NAME}"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" FORCE_GLOBAL=0 \
        SCRIPT_URL="${CI_SCRIPT_URL}" \
        sh "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-LC-01 zero-arg installed (global) exit 0" 0 "$_ec"
    assert_contains "TP-LC-01 global already installed" "$_out" "already installed"
    rm -f "${CI_GLOBAL_BIN}/${APP_NAME}"

    # TP-LC-04 about + version-check
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" FORCE_GLOBAL=0 \
        SCRIPT_URL="${CI_SCRIPT_URL}" \
        sh "${SCRIPT}" --json about 2>/dev/null
    )
    _ec=$?
    assert_eq "TP-LC-04 about after install exit 0" 0 "$_ec"
    assert_contains "TP-LC-04 about installed true" "$_out" '"installed":"true"'

    _is_latest_val="true"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" FORCE_GLOBAL=0 \
        PATH="${CI_USER_BIN}:${PATH}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        sh "${_bin}" --json version-check 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    _combo="${_out}${_err}"
    assert_eq "TP-LC-04 version-check --json exit 0" 0 "$_ec"
    assert_contains "TP-LC-04 version-check type" "$_combo" '"type":"version_check"'
    assert_contains "TP-LC-04 local_version key" "$_combo" "local_version"
    assert_contains "TP-LC-04 remote_version key" "$_combo" "remote_version"
    assert_contains "TP-LC-04 product version appears" "$_combo" "${PRODUCT_VERSION}"
    assert_contains "TP-LC-04 is_latest appears" "$_combo" "is_latest"

    # TP-LC-05 self-update already-latest
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" FORCE_GLOBAL=0 \
        PATH="${CI_USER_BIN}:${PATH}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        sh "${_bin}" --json self-update 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    _combo="${_out}${_err}"
    assert_eq "TP-LC-05 self-update already-latest exit 0" 0 "$_ec"
    assert_contains "TP-LC-05 already latest message" "$_combo" "Already running the latest version"

    # TP-CSUM-02 / TP-LC-06 human force reinstall transparency
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" FORCE_GLOBAL=0 \
        SCRIPT_URL="${CI_SCRIPT_URL}" \
        sh "${SCRIPT}" --force install 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-CSUM-02 human --force install exit 0" 0 "$_ec"
    assert_contains "TP-CSUM-02 companion link" "$_out" "Companion link:"
    assert_contains "TP-CSUM-02 expected digest" "$_out" "Expected SHA-256:"
    assert_contains "TP-CSUM-02 actual digest" "$_out" "Actual SHA-256:"
    assert_contains "TP-CSUM-02 PASS result" "$_out" "Automatic checksum result: PASS"

    # TP-LC-07 uninstall refuse / force
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" FORCE_GLOBAL=0 \
        PATH="${CI_USER_BIN}:${PATH}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        sh "${_bin}" --json self-uninstall 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    _combo="${_out}${_err}"
    assert_eq "TP-LC-07 self-uninstall --json no force exit 1" 1 "$_ec"
    assert_contains "TP-LC-07 confirm_required" "$_combo" "confirm_required"
    assert_file_exists "TP-LC-07 binary remains" "${_bin}"

    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" FORCE_GLOBAL=0 \
        PATH="${CI_USER_BIN}:${PATH}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        sh "${_bin}" --json --force self-uninstall 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-LC-07 self-uninstall --force exit 0" 0 "$_ec"
    assert_file_missing "TP-LC-07 binary removed" "${_bin}"

    # TP-CSUM-03 pin mismatch
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" FORCE_GLOBAL=0 \
        SCRIPT_URL="${CI_SCRIPT_URL}" \
        CHECKSUM="0000000000000000000000000000000000000000000000000000000000000000" \
        sh "${SCRIPT}" --json install 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    _combo="${_out}${_err}"
    assert_eq "TP-CSUM-03 CHECKSUM mismatch non-zero" 1 "$_ec"
    assert_contains "TP-CSUM-03 checksum_mismatch code" "$_combo" "checksum_mismatch"
    assert_file_missing "TP-CSUM-03 no install after bad pin" "${_bin}"

    # TP-CSUM-04 pin match
    _good=$(sha256sum "${SCRIPT}" | awk '{print $1}')
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" FORCE_GLOBAL=0 \
        SCRIPT_URL="${CI_SCRIPT_URL}" \
        CHECKSUM="${_good}" \
        sh "${SCRIPT}" --json install 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-CSUM-04 CHECKSUM match install exit 0" 0 "$_ec"
    assert_file_exists "TP-CSUM-04 install with good pin" "${_bin}"

    # TP-LC-08: ship implements ver_gt refuse; Core does not fetch an older remote artifact
    t_skip "TP-LC-08 downgrade refuse — ship has ver_gt; suite does not serve an older remote"

    # cleanup
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" FORCE_GLOBAL=0 \
        PATH="${CI_USER_BIN}:${PATH}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        sh "${_bin}" --json --force self-uninstall >/dev/null 2>&1 || true

    ci_stop_channel
    ci_cleanup_env
}

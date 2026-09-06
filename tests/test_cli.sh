# =============================================================================
# tests/test_cli.sh — Type 0 CLI surface + domain help rows (no host mutation)
# Maps: TP-CLI-*, TP-CSUM-01/05, TP-CNX-* help rows
# Primary law: requirement-shell-cli-interface, requirement-shell-cli-storage, zero-arguments, domain-certbot-nginx
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_cli() {
    t_header "CLI surface (TP-CLI)"

    require_cmd sh
    require_cmd sha256sum
    require_cmd grep
    require_cmd python3

    _HOST_HOME="${HOME:-}"
    _HOST_PERSIST=""
    _host_persist_existed=0
    if [ -n "${_HOST_HOME}" ]; then
        _HOST_PERSIST="${_HOST_HOME}/.local/${APP_NAME}"
        [ -e "${_HOST_PERSIST}" ] && _host_persist_existed=1
    fi

    # Isolate HOME so cache/persistence mkdir cannot touch the host tree.
    ci_isolated_env

    # TP-CLI-01 syntax + companion
    sh -n "${SCRIPT}"
    assert_eq "TP-CLI-01 sh -n ship unit" 0 "$?"

    if [ -f "${REPO_ROOT}/${APP_NAME}.sha256" ]; then
        _expected=$(awk '{print $1; exit}' "${REPO_ROOT}/${APP_NAME}.sha256" | tr -d ' \n\r\t')
        _actual=$(sha256sum "${SCRIPT}" | awk '{print $1}')
        assert_eq "TP-CLI-01 / TP-CSUM-01 companion matches ship unit" "$_expected" "$_actual"
    else
        t_fail "TP-CSUM-01 ${APP_NAME}.sha256 missing at repo root"
    fi

    # TP-CLI-02 version
    _out=$(sh "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-02 version exit 0" 0 "$_ec"
    assert_contains "TP-CLI-02 version human product version" "$_out" "${PRODUCT_VERSION}"
    assert_contains "TP-CLI-02 version human app" "$_out" "${APP_NAME}"

    _out=$(sh "${SCRIPT}" --json version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-02 version --json exit 0" 0 "$_ec"
    assert_contains "TP-CLI-02 version --json type" "$_out" '"type":"version"'
    assert_contains "TP-CLI-02 version --json app" "$_out" "\"app\":\"${APP_NAME}\""
    assert_contains "TP-CLI-02 version --json field" "$_out" "\"version\":\"${PRODUCT_VERSION}\""

    # TP-CLI-03 help Type 0 + domain; no CHECKSUM
    _out=$(sh "${SCRIPT}" help 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-03 help exit 0" 0 "$_ec"
    assert_contains "TP-CLI-03 help install" "$_out" "install"
    assert_contains "TP-CLI-03 help version-check" "$_out" "version-check"
    assert_contains "TP-CLI-03 help self-update" "$_out" "self-update"
    assert_contains "TP-CLI-03 help self-uninstall" "$_out" "self-uninstall"
    assert_contains "TP-CLI-03 help about" "$_out" "about"
    assert_contains "TP-CLI-03 help setup" "$_out" "setup"
    assert_contains "TP-CLI-03 help domains" "$_out" "domains"
    assert_contains "TP-CLI-03 help email" "$_out" "email"
    assert_contains "TP-CLI-03 help nginx-conf" "$_out" "nginx-conf"
    assert_contains "TP-CLI-03 help --json" "$_out" "--json"
    assert_contains "TP-CLI-03 help --no-cloudflare" "$_out" "--no-cloudflare"
    assert_not_contains "TP-CSUM-05 help must not list CHECKSUM" "$_out" "CHECKSUM"
    assert_not_contains "TP-CLI-03 help no foreign timer DNA" "$_out" "timer"
    assert_not_contains "TP-CLI-03 help no Java DNA" "$_out" "Java"
    assert_not_contains "TP-CLI-03 help no pom.xml DNA" "$_out" "pom.xml"

    # TP-CLI-04 help/about JSON
    _out=$(sh "${SCRIPT}" --json help 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-04 help --json exit 0" 0 "$_ec"
    assert_contains "TP-CLI-04 help --json type success" "$_out" '"type":"success"'

    _out=$(sh "${SCRIPT}" --json about 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-04 about --json exit 0" 0 "$_ec"
    assert_contains "TP-CLI-04 about --json type" "$_out" '"type":"about"'
    assert_contains "TP-CLI-04 about --json app" "$_out" "\"app\":\"${APP_NAME}\""
    assert_not_contains "TP-CSUM-05 about --json no CHECKSUM" "$_out" "CHECKSUM"
    # domain about extras allowed
    assert_contains "TP-CNX-01 about nginx platform field" "$_out" "nginx_platform"
    _uname=$(id -un 2>/dev/null || echo unknown)
    _pref=$(json_get cache_preferred "$_out")
    _tmpc=$(json_get cache_tmp "$_out")
    _fall=$(json_get cache_fallback "$_out")
    _pers=$(json_get persistence_storage "$_out")
    _eff=$(json_get effective_storage "$_out")
    _sdir=$(json_get storage_dir "$_out")
    assert_eq "TP-CLI-05 about cache_preferred" "/dev/shm/${APP_NAME}-${_uname}" "$_pref"
    assert_eq "TP-CLI-05 about cache_tmp" "/tmp/${APP_NAME}-${_uname}" "$_tmpc"
    assert_eq "TP-CLI-05 about cache_fallback" "${HOME}/.cache/${APP_NAME}-${_uname}" "$_fall"
    assert_eq "TP-CLI-05 about persistence_storage path" "${HOME}/.local/${APP_NAME}" "$_pers"
    assert_contains "TP-CLI-05 about effective_storage non-empty" "$_eff" "/"
    assert_contains "TP-CLI-05 about storage_dir non-empty" "$_sdir" "/"
    if [ "$_pers" = "${HOME}/.local/bin" ]; then
        t_fail "TP-CLI-05 persistence_storage must not be USER_BIN"
    else
        t_pass "TP-CLI-05 persistence_storage is not USER_BIN"
    fi
    assert_file_exists "TP-CLI-05 persistence folder exists" "${HOME}/.local/${APP_NAME}"
    if [ -d /dev/shm ] && [ -w /dev/shm ]; then
        assert_eq "TP-CLI-05 effective is preferred when /dev/shm writable" "$_pref" "$_eff"
    else
        case "$_eff" in
            "$_tmpc"|"$_fall") t_pass "TP-CLI-05 effective is tmp or fallback when shm unusable" ;;
            *) t_fail "TP-CLI-05 effective_storage '$_eff' not tmp/fallback when shm unusable" ;;
        esac
    fi

    _hout=$(sh "${SCRIPT}" about 2>/dev/null)
    _hec=$?
    assert_eq "TP-CLI-05 about human exit 0" 0 "$_hec"
    assert_contains "TP-CLI-05 about human Cache folder preferred" "$_hout" "Cache folder (preferred): ${_pref}"
    assert_contains "TP-CLI-05 about human Cache folder tmp" "$_hout" "Cache folder (tmp):       ${_tmpc}"
    assert_contains "TP-CLI-05 about human Cache folder fallback" "$_hout" "Cache folder (fallback):  ${_fall}"
    assert_contains "TP-CLI-05 about human Cache folder in use" "$_hout" "Cache folder (in use):    ${_eff}"
    assert_contains "TP-CLI-05 about human Persistence storage" "$_hout" "Persistence storage:      ${_pers}"
    assert_not_contains "TP-CLI-05 about human no Storage (effective)" "$_hout" "Effective storage"
    assert_not_contains "TP-CLI-05 about human no Storage fallback" "$_hout" "Storage fallback"

    # TP-CLI-05 fail-closed persistence mkdir + JSON Next:
    _local_dir="${HOME}/.local"
    rm -rf "${_local_dir}"
    mkdir -p "${HOME}"
    : > "${_local_dir}"
    _fout=$(sh "${SCRIPT}" --json about 2>/dev/null)
    _fec=$?
    assert_eq "TP-CLI-05 persistence mkdir fail exit 1" 1 "$_fec"
    assert_contains "TP-CLI-05 persistence fail JSON type" "$_fout" '"type":"error"'
    assert_contains "TP-CLI-05 persistence fail Next" "$_fout" "Next:"
    assert_contains "TP-CLI-05 persistence fail sentence" "$_fout" "Could not create persistence folder"
    rm -f "${_local_dir}"
    mkdir -p "${CI_USER_BIN}"

    # TP-CLI-06 unknown
    _err=$(sh "${SCRIPT}" no-such-command 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-06 unknown exit 1" 1 "$_ec"
    assert_contains "TP-CLI-06 unknown error text" "$_err" "Unknown argument"

    # JSON errors are emitted on stdout (output_json)
    _out=$(sh "${SCRIPT}" --json no-such-command 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-06 unknown --json exit 1" 1 "$_ec"
    assert_contains "TP-CLI-06 unknown --json type error" "$_out" '"type":"error"'
    assert_contains "TP-CLI-06 unknown --json code" "$_out" "bad_argument"

    # TP-CLI-07 quiet
    _out=$(sh "${SCRIPT}" --quiet version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-07 version --quiet exit 0" 0 "$_ec"
    _trim=$(printf '%s' "$_out" | tr -d ' \t\n\r')
    if [ -z "$_trim" ]; then
        t_pass "TP-CLI-07 version --quiet suppresses human info"
    else
        t_fail "TP-CLI-07 version --quiet expected empty stdout, got '$(_trunc "$_out")'"
    fi

    # TP-CLI-08 / TP-U-01 env -u HOME — stub getent so reconstructed HOME stays isolated.
    _iso_home="${CI_HOME}"
    _getent_dir="${CI_HOME}/.getent-bin"
    mkdir -p "${_getent_dir}"
    printf '%s\n' "#!/bin/sh" \
        "if [ \"\$1\" = passwd ]; then" \
        "  printf '%s\\n' \"user:x:1000:1000::${_iso_home}:/bin/sh\"" \
        "  exit 0" \
        "fi" \
        "command -p getent \"\$@\" 2>/dev/null || exit 1" > "${_getent_dir}/getent"
    chmod +x "${_getent_dir}/getent"
    _out=$(env -u HOME PATH="${_getent_dir}:${PATH}" sh "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-08 env -u HOME version exit 0" 0 "$_ec"
    assert_contains "TP-CLI-08 env -u HOME still reports version" "$_out" "${PRODUCT_VERSION}"
    assert_file_exists "TP-CLI-08 persistence under isolated reconstructed HOME" "${_iso_home}/.local/${APP_NAME}"
    if [ "${_host_persist_existed}" -eq 0 ] && [ -n "${_HOST_PERSIST}" ]; then
        assert_file_missing "TP-CLI-08 did not mkdir host persistence" "${_HOST_PERSIST}"
    else
        t_pass "TP-CLI-08 host persistence pre-existed or HOST HOME empty (skip missing assert)"
    fi

    # TP-CLI-09 / TP-LC-09 zero-arg bad channel
    ci_cleanup_env
    ci_isolated_env
    _errf="${CI_HOME}/zero-arg-err.txt"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" FORCE_GLOBAL=0 \
        SCRIPT_URL="http://127.0.0.1:1/${APP_NAME}-unreachable" \
        sh "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    if [ "$_ec" -ne 0 ]; then
        t_pass "TP-CLI-09 zero-arg failed install exits non-zero"
    else
        t_fail "TP-CLI-09 zero-arg failed install expected non-zero, got 0"
    fi
    assert_file_missing "TP-CLI-09 no binary after failed zero-arg" "${CI_USER_BIN}/${APP_NAME}"
    # non-silent
    if [ -n "$_out$_err" ]; then
        t_pass "TP-CLI-09 zero-arg fail is not silent"
    else
        t_fail "TP-CLI-09 zero-arg fail was silent (0-byte out+err)"
    fi
    ci_cleanup_env

    # TP-CLI-11 self-uninstall fail-closed JSON
    ci_isolated_env
    mkdir -p "${CI_USER_BIN}"
    cp "${SCRIPT}" "${CI_USER_BIN}/${APP_NAME}"
    chmod +x "${CI_USER_BIN}/${APP_NAME}"
    _errf="${CI_HOME}/un-err.txt"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" FORCE_GLOBAL=0 \
        sh "${SCRIPT}" --json self-uninstall 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    _combo="${_out}${_err}"
    assert_eq "TP-CLI-11 self-uninstall --json no force exit 1" 1 "$_ec"
    assert_contains "TP-CLI-11 confirm_required code" "$_combo" "confirm_required"
    assert_file_exists "TP-CLI-11 binary remains without --force" "${CI_USER_BIN}/${APP_NAME}"
    ci_cleanup_env
}

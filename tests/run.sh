#!/bin/sh
# =============================================================================
# tests/run.sh — CI entrypoint for certbot-nginx
# =============================================================================
#
# Usage:
#   ./tests/run.sh
#   sh tests/run.sh
#
# Exit 0 when all assertions pass; non-zero when any fail.
# No root, no public network for Core cases (local channel only).
# =============================================================================

set -u

TESTS_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "${TESTS_ROOT}/.." && pwd)
export TESTS_ROOT REPO_ROOT
APP_NAME="certbot-nginx"
SCRIPT="${REPO_ROOT}/${APP_NAME}"
export SCRIPT APP_NAME

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"
# shellcheck source=test_cli.sh
. "${TESTS_ROOT}/test_cli.sh"
# shellcheck source=test_install_lifecycle.sh
. "${TESTS_ROOT}/test_install_lifecycle.sh"
# shellcheck source=test_domain_surface.sh
. "${TESTS_ROOT}/test_domain_surface.sh"

PASS=0
FAIL=0
SKIP=0

_cleanup() {
    ci_stop_channel 2>/dev/null || true
    ci_cleanup_env 2>/dev/null || true
}
trap _cleanup EXIT INT HUP TERM

printf 'certbot-nginx CI tests\n'
printf 'script: %s\n' "${SCRIPT}"
printf 'version: %s\n' "${PRODUCT_VERSION}"

if [ ! -f "${SCRIPT}" ]; then
    printf 'ERROR: ship unit missing: %s\n' "${SCRIPT}" >&2
    exit 2
fi
if [ ! -x "${SCRIPT}" ]; then
    chmod +x "${SCRIPT}" 2>/dev/null || true
fi

run_test_cli
run_test_install_lifecycle
run_test_domain_surface

printf '\n== summary ==\n'
printf 'PASS=%s FAIL=%s SKIP=%s\n' "${PASS}" "${FAIL}" "${SKIP}"

if [ "${FAIL}" -gt 0 ]; then
    printf 'RESULT: FAILED\n' >&2
    exit 1
fi

printf 'RESULT: OK\n'
exit 0

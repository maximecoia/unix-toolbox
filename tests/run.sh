#!/bin/sh

set -u

TEST_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
passed=0
skipped=0
failed=0

for suite in \
    "$TEST_DIR/test_mini_echo.sh" \
    "$TEST_DIR/test_mini_cat.sh" \
    "$TEST_DIR/test_mini_cp.sh" \
    "$TEST_DIR/test_mini_wc.sh"
do
    printf '\n==> %s\n' "$(basename "$suite")"
    sh "$suite"
    status=$?
    case "$status" in
        0) passed=$((passed + 1)) ;;
        77) skipped=$((skipped + 1)) ;;
        *) failed=$((failed + 1)) ;;
    esac
done

printf '\nSuites: %d passed, %d skipped, %d failed\n' \
    "$passed" "$skipped" "$failed"

[ "$failed" -eq 0 ]

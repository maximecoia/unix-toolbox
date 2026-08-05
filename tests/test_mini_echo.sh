#!/bin/sh

set -u

TEST_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
. "$TEST_DIR/common.sh"

skip_if_todo mini_echo
require_binary mini_echo
BIN="$BIN_DIR/mini_echo"
TMP=$(new_tmpdir)
trap 'rm -rf "$TMP"' 0 HUP INT TERM

printf '\n' > "$TMP/expected"
"$BIN" > "$TMP/actual" 2> "$TMP/stderr" || fail 'zero operands failed'
assert_files_equal "$TMP/expected" "$TMP/actual" 'zero operands output'
assert_empty_file "$TMP/stderr" 'zero operands stderr'

printf 'hello\n' > "$TMP/expected"
"$BIN" hello > "$TMP/actual" 2> "$TMP/stderr" || fail 'one operand failed'
assert_files_equal "$TMP/expected" "$TMP/actual" 'one operand output'
assert_empty_file "$TMP/stderr" 'one operand stderr'

printf 'hello unix world\n' > "$TMP/expected"
"$BIN" hello unix world > "$TMP/actual" 2> "$TMP/stderr" || fail 'multiple operands failed'
assert_files_equal "$TMP/expected" "$TMP/actual" 'multiple operands output'

printf 'hello world  tail\n' > "$TMP/expected"
"$BIN" 'hello world' '' tail > "$TMP/actual" 2> "$TMP/stderr" || fail 'spaced and empty operands failed'
assert_files_equal "$TMP/expected" "$TMP/actual" 'spaced and empty operands output'

printf '%s\n' '-n hello' > "$TMP/expected"
"$BIN" -n hello > "$TMP/actual" 2> "$TMP/stderr" || fail 'dash-prefixed operand failed'
assert_files_equal "$TMP/expected" "$TMP/actual" 'dash-prefixed operand output'

printf 'PASS: mini_echo\n'

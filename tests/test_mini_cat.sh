#!/bin/sh

set -u

TEST_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
. "$TEST_DIR/common.sh"

skip_if_todo mini_cat
require_binary mini_cat
BIN="$BIN_DIR/mini_cat"
TMP=$(new_tmpdir)
trap 'rm -rf "$TMP"' 0 HUP INT TERM

printf 'alpha\nbeta\n' > "$TMP/expected"
"$BIN" "$TMP/expected" > "$TMP/actual" 2> "$TMP/stderr" || fail 'text file copy failed'
assert_files_equal "$TMP/expected" "$TMP/actual" 'text file bytes'
assert_empty_file "$TMP/stderr" 'text file stderr'

printf '0123456789abcdef\n' > "$TMP/expected"
"$BIN" "$TMP/expected" > "$TMP/actual" 2> "$TMP/stderr" || fail 'multi-read file failed'
assert_files_equal "$TMP/expected" "$TMP/actual" 'multi-read bytes'

: > "$TMP/empty"
"$BIN" "$TMP/empty" > "$TMP/actual" 2> "$TMP/stderr" || fail 'empty file failed'
assert_empty_file "$TMP/actual" 'empty file output'

printf '\000\001hello\377\n' > "$TMP/binary"
"$BIN" "$TMP/binary" > "$TMP/actual" 2> "$TMP/stderr" || fail 'binary file failed'
assert_files_equal "$TMP/binary" "$TMP/actual" 'binary byte preservation'

set +e
"$BIN" > "$TMP/actual" 2> "$TMP/stderr"
status=$?
set -e
assert_nonzero "$status" 'missing operand'

set +e
"$BIN" "$TMP/expected" "$TMP/empty" > "$TMP/actual" 2> "$TMP/stderr"
status=$?
set -e
assert_nonzero "$status" 'too many operands'

set +e
"$BIN" "$TMP/missing" > "$TMP/actual" 2> "$TMP/stderr"
status=$?
set -e
assert_nonzero "$status" 'missing file'

printf 'PASS: mini_cat\n'

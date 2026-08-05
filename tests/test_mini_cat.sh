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
"$BIN" < "$TMP/expected" > "$TMP/actual" 2> "$TMP/stderr" || fail 'stdin copy failed'
assert_files_equal "$TMP/expected" "$TMP/actual" 'stdin bytes'
assert_empty_file "$TMP/stderr" 'stdin stderr'

: > "$TMP/empty"
"$BIN" "$TMP/empty" > "$TMP/actual" 2> "$TMP/stderr" || fail 'empty file failed'
assert_empty_file "$TMP/actual" 'empty file output'

printf 'first\n' > "$TMP/first"
printf 'second\n' > "$TMP/second"
cat "$TMP/first" "$TMP/second" > "$TMP/expected"
"$BIN" "$TMP/first" "$TMP/second" > "$TMP/actual" 2> "$TMP/stderr" || fail 'multiple files failed'
assert_files_equal "$TMP/expected" "$TMP/actual" 'multiple file order'

printf 'middle\n' > "$TMP/middle"
cat "$TMP/first" "$TMP/middle" "$TMP/second" > "$TMP/expected"
"$BIN" "$TMP/first" - "$TMP/second" < "$TMP/middle" > "$TMP/actual" 2> "$TMP/stderr" || fail 'dash stdin operand failed'
assert_files_equal "$TMP/expected" "$TMP/actual" 'dash stdin placement'

printf '\000\001hello\377\n' > "$TMP/binary"
"$BIN" "$TMP/binary" > "$TMP/actual" 2> "$TMP/stderr" || fail 'binary file failed'
assert_files_equal "$TMP/binary" "$TMP/actual" 'binary byte preservation'

set +e
"$BIN" "$TMP/missing" > "$TMP/actual" 2> "$TMP/stderr"
status=$?
set -e
assert_nonzero "$status" 'missing file'
assert_nonempty_file "$TMP/stderr" 'missing file stderr'

printf 'PASS: mini_cat\n'

#!/bin/sh

set -u

TEST_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
. "$TEST_DIR/common.sh"

skip_if_todo mini_cp
require_binary mini_cp
BIN="$BIN_DIR/mini_cp"
TMP=$(new_tmpdir)
trap 'rm -rf "$TMP"' 0 HUP INT TERM

printf 'alpha\nbeta\n' > "$TMP/source"
"$BIN" "$TMP/source" "$TMP/destination" > "$TMP/stdout" 2> "$TMP/stderr" || fail 'text copy failed'
assert_files_equal "$TMP/source" "$TMP/destination" 'text copy bytes'
assert_empty_file "$TMP/stdout" 'text copy stdout'
assert_empty_file "$TMP/stderr" 'text copy stderr'

: > "$TMP/empty"
"$BIN" "$TMP/empty" "$TMP/empty-copy" > "$TMP/stdout" 2> "$TMP/stderr" || fail 'empty copy failed'
assert_files_equal "$TMP/empty" "$TMP/empty-copy" 'empty copy bytes'

printf '\000\001hello\377\n' > "$TMP/binary"
"$BIN" "$TMP/binary" "$TMP/binary-copy" > "$TMP/stdout" 2> "$TMP/stderr" || fail 'binary copy failed'
assert_files_equal "$TMP/binary" "$TMP/binary-copy" 'binary copy bytes'

printf 'long stale destination content\n' > "$TMP/overwrite"
printf 'new\n' > "$TMP/short"
"$BIN" "$TMP/short" "$TMP/overwrite" > "$TMP/stdout" 2> "$TMP/stderr" || fail 'overwrite copy failed'
assert_files_equal "$TMP/short" "$TMP/overwrite" 'destination truncation'

set +e
"$BIN" > "$TMP/stdout" 2> "$TMP/stderr"
status=$?
set -e
assert_nonzero "$status" 'zero-argument usage'
assert_nonempty_file "$TMP/stderr" 'zero-argument usage stderr'

set +e
"$BIN" "$TMP/source" "$TMP/destination" extra > "$TMP/stdout" 2> "$TMP/stderr"
status=$?
set -e
assert_nonzero "$status" 'extra-argument usage'
assert_nonempty_file "$TMP/stderr" 'extra-argument usage stderr'

set +e
"$BIN" "$TMP/missing" "$TMP/destination" > "$TMP/stdout" 2> "$TMP/stderr"
status=$?
set -e
assert_nonzero "$status" 'missing source'
assert_nonempty_file "$TMP/stderr" 'missing source stderr'

printf 'PASS: mini_cp\n'

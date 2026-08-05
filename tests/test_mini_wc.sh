#!/bin/sh

set -u

TEST_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
. "$TEST_DIR/common.sh"

skip_if_todo mini_wc
require_binary mini_wc
BIN="$BIN_DIR/mini_wc"
TMP=$(new_tmpdir)
trap 'rm -rf "$TMP"' 0 HUP INT TERM
export LC_ALL=C

: > "$TMP/empty"
printf '0 0 0\n' > "$TMP/expected"
"$BIN" < "$TMP/empty" > "$TMP/actual" 2> "$TMP/stderr" || fail 'empty stdin failed'
assert_files_equal "$TMP/expected" "$TMP/actual" 'empty stdin counts'
assert_empty_file "$TMP/stderr" 'empty stdin stderr'

printf 'hello world\nsecond line\n' > "$TMP/input"
printf '2 4 24\n' > "$TMP/expected"
"$BIN" < "$TMP/input" > "$TMP/actual" 2> "$TMP/stderr" || fail 'known stdin failed'
assert_files_equal "$TMP/expected" "$TMP/actual" 'known stdin counts'

printf '\talpha  beta\n\n' > "$TMP/whitespace"
printf '2 2 14\n' > "$TMP/expected"
"$BIN" < "$TMP/whitespace" > "$TMP/actual" 2> "$TMP/stderr" || fail 'whitespace transitions failed'
assert_files_equal "$TMP/expected" "$TMP/actual" 'whitespace transition counts'

printf 'abc' > "$TMP/no-newline"
printf '0 1 3\n' > "$TMP/expected"
"$BIN" < "$TMP/no-newline" > "$TMP/actual" 2> "$TMP/stderr" || fail 'no final newline failed'
assert_files_equal "$TMP/expected" "$TMP/actual" 'no final newline counts'

printf 'one two\n' > "$TMP/first"
printf '3 4 5\n' > "$TMP/second"
printf '1 2 8 %s\n1 3 6 %s\n' "$TMP/first" "$TMP/second" > "$TMP/expected"
"$BIN" "$TMP/first" "$TMP/second" > "$TMP/actual" 2> "$TMP/stderr" || fail 'multiple files failed'
assert_files_equal "$TMP/expected" "$TMP/actual" 'multiple file records'
assert_empty_file "$TMP/stderr" 'multiple file stderr'

set +e
"$BIN" "$TMP/missing" > "$TMP/actual" 2> "$TMP/stderr"
status=$?
set -e
assert_nonzero "$status" 'missing file'
assert_nonempty_file "$TMP/stderr" 'missing file stderr'

printf 'PASS: mini_wc\n'

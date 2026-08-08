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
printf '0 0 0 %s\n' "$TMP/empty" > "$TMP/expected"
"$BIN" "$TMP/empty" > "$TMP/actual" 2> "$TMP/stderr" \
    || fail 'empty file failed'
assert_files_equal "$TMP/expected" "$TMP/actual" 'empty file counts'
assert_empty_file "$TMP/stderr" 'empty file stderr'

printf 'hello world\nsecond line\n' > "$TMP/input"
printf '2 4 24 %s\n' "$TMP/input" > "$TMP/expected"
"$BIN" "$TMP/input" > "$TMP/actual" 2> "$TMP/stderr" \
    || fail 'known file failed'
assert_files_equal "$TMP/expected" "$TMP/actual" 'known file counts'
assert_empty_file "$TMP/stderr" 'known file stderr'

printf 'abc' > "$TMP/no-newline"
printf '0 1 3 %s\n' "$TMP/no-newline" > "$TMP/expected"
"$BIN" "$TMP/no-newline" > "$TMP/actual" 2> "$TMP/stderr" \
    || fail 'no final newline failed'
assert_files_equal "$TMP/expected" "$TMP/actual" 'no final newline counts'

printf 'a b\tc\nd\013e\014f\015g' > "$TMP/whitespace"
printf '1 7 13 %s\n' "$TMP/whitespace" > "$TMP/expected"
"$BIN" "$TMP/whitespace" > "$TMP/actual" 2> "$TMP/stderr" \
    || fail 'whitespace classification failed'
assert_files_equal "$TMP/expected" "$TMP/actual" 'whitespace counts'

i=0
: > "$TMP/cross-buffer-word"
while [ "$i" -lt 1100 ]; do
    printf 'a' >> "$TMP/cross-buffer-word"
    i=$((i + 1))
done
printf ' b\n' >> "$TMP/cross-buffer-word"
printf '1 2 1103 %s\n' "$TMP/cross-buffer-word" > "$TMP/expected"
"$BIN" "$TMP/cross-buffer-word" > "$TMP/actual" 2> "$TMP/stderr" \
    || fail 'cross-buffer word failed'
assert_files_equal "$TMP/expected" "$TMP/actual" \
    'word state survives buffer boundary'

i=0
: > "$TMP/boundary-space"
while [ "$i" -lt 1023 ]; do
    printf 'a' >> "$TMP/boundary-space"
    i=$((i + 1))
done
printf ' b\n' >> "$TMP/boundary-space"
printf '1 2 1026 %s\n' "$TMP/boundary-space" > "$TMP/expected"
"$BIN" "$TMP/boundary-space" > "$TMP/actual" 2> "$TMP/stderr" \
    || fail 'boundary whitespace failed'
assert_files_equal "$TMP/expected" "$TMP/actual" \
    'separator at read boundary'

printf 'one two\n' > "$TMP/file with spaces"
printf '1 2 8 %s\n' "$TMP/file with spaces" > "$TMP/expected"
"$BIN" "$TMP/file with spaces" > "$TMP/actual" 2> "$TMP/stderr" \
    || fail 'filename with spaces failed'
assert_files_equal "$TMP/expected" "$TMP/actual" 'filename output'

set +e
"$BIN" > "$TMP/actual" 2> "$TMP/stderr"
status=$?
set -e
assert_nonzero "$status" 'missing operand'
assert_empty_file "$TMP/actual" 'missing operand stdout'

set +e
"$BIN" "$TMP/input" "$TMP/empty" > "$TMP/actual" 2> "$TMP/stderr"
status=$?
set -e
assert_nonzero "$status" 'extra operand'
assert_empty_file "$TMP/actual" 'extra operand stdout'

set +e
"$BIN" "$TMP/missing" > "$TMP/actual" 2> "$TMP/stderr"
status=$?
set -e
assert_nonzero "$status" 'missing file'
assert_empty_file "$TMP/actual" 'missing file stdout'

set +e
"$BIN" "$TMP/input" 1>&- 2> "$TMP/stderr"
status=$?
set -e
assert_nonzero "$status" 'closed stdout'

printf 'PASS: mini_wc\n'

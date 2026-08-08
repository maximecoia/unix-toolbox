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
"$BIN" "$TMP/source" "$TMP/destination" > "$TMP/stdout" 2> "$TMP/stderr" \
    || fail 'text copy failed'
assert_files_equal "$TMP/source" "$TMP/destination" 'text copy bytes'
assert_empty_file "$TMP/stdout" 'text copy stdout'
assert_empty_file "$TMP/stderr" 'text copy stderr'

: > "$TMP/empty"
"$BIN" "$TMP/empty" "$TMP/empty-copy" > "$TMP/stdout" 2> "$TMP/stderr" \
    || fail 'empty copy failed'
assert_files_equal "$TMP/empty" "$TMP/empty-copy" 'empty copy bytes'

i=0
: > "$TMP/large"
while [ "$i" -lt 300 ]; do
    printf '0123456789abcdef' >> "$TMP/large"
    i=$((i + 1))
done
"$BIN" "$TMP/large" "$TMP/large-copy" > "$TMP/stdout" 2> "$TMP/stderr" \
    || fail 'large copy failed'
assert_files_equal "$TMP/large" "$TMP/large-copy" 'multi-read copy bytes'

printf '\000\001hello\377\n' > "$TMP/binary"
"$BIN" "$TMP/binary" "$TMP/binary-copy" > "$TMP/stdout" 2> "$TMP/stderr" \
    || fail 'binary copy failed'
assert_files_equal "$TMP/binary" "$TMP/binary-copy" 'binary copy bytes'

printf 'long stale destination content\n' > "$TMP/overwrite"
printf 'new\n' > "$TMP/short"
"$BIN" "$TMP/short" "$TMP/overwrite" > "$TMP/stdout" 2> "$TMP/stderr" \
    || fail 'overwrite copy failed'
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

set +e
"$BIN" "$TMP/source" "$TMP/no-such-directory/destination" \
    > "$TMP/stdout" 2> "$TMP/stderr"
status=$?
set -e
assert_nonzero "$status" 'invalid destination'
assert_nonempty_file "$TMP/stderr" 'invalid destination stderr'

printf 'must survive same-path rejection\n' > "$TMP/same"
cp "$TMP/same" "$TMP/same-expected"
set +e
"$BIN" "$TMP/same" "$TMP/same" > "$TMP/stdout" 2> "$TMP/stderr"
status=$?
set -e
assert_nonzero "$status" 'same pathname'
assert_nonempty_file "$TMP/stderr" 'same pathname stderr'
assert_files_equal "$TMP/same-expected" "$TMP/same" 'same pathname preserves source'

mkdir "$TMP/path-alias"
printf 'must survive path-alias rejection\n' > "$TMP/path-source"
cp "$TMP/path-source" "$TMP/path-source-expected"
set +e
"$BIN" "$TMP/path-source" "$TMP/path-alias/../path-source" \
    > "$TMP/stdout" 2> "$TMP/stderr"
status=$?
set -e
assert_nonzero "$status" 'different path to same file'
assert_nonempty_file "$TMP/stderr" 'different path stderr'
assert_files_equal "$TMP/path-source-expected" "$TMP/path-source" \
    'different path preserves source'

printf 'must survive hard-link rejection\n' > "$TMP/hard-source"
ln "$TMP/hard-source" "$TMP/hard-alias"
cp "$TMP/hard-source" "$TMP/hard-expected"
set +e
"$BIN" "$TMP/hard-source" "$TMP/hard-alias" > "$TMP/stdout" 2> "$TMP/stderr"
status=$?
set -e
assert_nonzero "$status" 'hard-link destination'
assert_nonempty_file "$TMP/stderr" 'hard-link stderr'
assert_files_equal "$TMP/hard-expected" "$TMP/hard-source" \
    'hard-link rejection preserves source'
assert_files_equal "$TMP/hard-source" "$TMP/hard-alias" \
    'hard-link alias remains intact'

printf 'PASS: mini_cp\n'

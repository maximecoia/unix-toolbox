#!/bin/sh

set -u

TEST_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
. "$TEST_DIR/common.sh"

# bin/short/ holds the same utilities, rebuilt with every write() redirected to
# tests/short_write.c, which writes one byte per call. mini_echo is left out:
# it already writes one byte per call, so there is nothing to shorten.
SHORT_DIR="$BIN_DIR/short"
for program in mini_cat mini_cp mini_wc; do
    [ -x "$SHORT_DIR/$program" ] || fail "$SHORT_DIR/$program is not executable"
done
require_binary mini_wc

TMP=$(new_tmpdir)
trap 'rm -rf "$TMP"' 0 HUP INT TERM
LOG="$TMP/short-calls"

# 2700 bytes: many reads of mini_cat's 4-byte buffer, and three reads of the
# 1024-byte buffer of mini_cp, the last one partial.
i=0
: > "$TMP/input"
while [ "$i" -lt 300 ]; do
    printf 'line %03d\n' "$i" >> "$TMP/input"
    i=$((i + 1))
done

rm -f "$LOG"
SHORT_WRITE_LOG="$LOG" "$SHORT_DIR/mini_cat" "$TMP/input" \
    > "$TMP/actual" 2> "$TMP/stderr" || fail 'mini_cat under short writes failed'
assert_files_equal "$TMP/input" "$TMP/actual" 'mini_cat bytes under short writes'
assert_nonempty_file "$LOG" 'mini_cat shortened calls'

rm -f "$LOG"
SHORT_WRITE_LOG="$LOG" "$SHORT_DIR/mini_cp" "$TMP/input" "$TMP/copy" \
    > "$TMP/actual" 2> "$TMP/stderr" || fail 'mini_cp under short writes failed'
assert_files_equal "$TMP/input" "$TMP/copy" 'mini_cp bytes under short writes'
assert_nonempty_file "$LOG" 'mini_cp shortened calls'

# The reference is the regular build, whose counts its own suite checks.
"$BIN_DIR/mini_wc" "$TMP/input" > "$TMP/expected" 2> "$TMP/stderr" \
    || fail 'mini_wc reference failed'
rm -f "$LOG"
SHORT_WRITE_LOG="$LOG" "$SHORT_DIR/mini_wc" "$TMP/input" \
    > "$TMP/actual" 2> "$TMP/stderr" || fail 'mini_wc under short writes failed'
assert_files_equal "$TMP/expected" "$TMP/actual" 'mini_wc output under short writes'
assert_nonempty_file "$LOG" 'mini_wc shortened calls'

printf 'PASS: short writes\n'

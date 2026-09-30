#!/bin/sh

set -u

TEST_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
. "$TEST_DIR/common.sh"

# bin/read_fault/mini_cp is the same source, rebuilt with every read() sent to
# tests/read_fault.c, which fails when READ_FAULT asks it to.
BIN="$BIN_DIR/read_fault/mini_cp"
[ -x "$BIN" ] || fail "$BIN is not executable"

TMP=$(new_tmpdir)
trap 'rm -rf "$TMP"' 0 HUP INT TERM
LOG="$TMP/faults"

# 2700 bytes, so the first read() fills mini_cp's 1024-byte buffer and the
# failure lands in the middle of the copy, not before it.
i=0
: > "$TMP/input"
while [ "$i" -lt 300 ]; do
    printf 'line %03d\n' "$i" >> "$TMP/input"
    i=$((i + 1))
done

# With no fault asked for, the stand-in is the real read().
"$BIN" "$TMP/input" "$TMP/copy" > "$TMP/actual" 2> "$TMP/stderr" \
    || fail 'mini_cp without faults failed'
assert_files_equal "$TMP/input" "$TMP/copy" 'mini_cp bytes without faults'

# A read() that fails after the first chunk must fail the copy, not end it.
rm -f "$LOG" "$TMP/copy"
set +e
READ_FAULT=eio READ_FAULT_LOG="$LOG" "$BIN" "$TMP/input" "$TMP/copy" \
    > "$TMP/actual" 2> "$TMP/stderr"
status=$?
set -e
assert_nonzero "$status" 'mini_cp read error'
assert_nonempty_file "$TMP/stderr" 'mini_cp read error stderr'
assert_nonempty_file "$LOG" 'mini_cp injected read errors'

# A read() interrupted by a signal is retried, and the copy is still whole.
rm -f "$LOG" "$TMP/copy"
READ_FAULT=eintr READ_FAULT_LOG="$LOG" "$BIN" "$TMP/input" "$TMP/copy" \
    > "$TMP/actual" 2> "$TMP/stderr" || fail 'mini_cp after an interrupted read failed'
assert_files_equal "$TMP/input" "$TMP/copy" 'mini_cp bytes after an interrupted read'
assert_nonempty_file "$LOG" 'mini_cp interrupted reads'

printf 'PASS: read faults\n'

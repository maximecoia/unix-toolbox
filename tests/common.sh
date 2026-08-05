#!/bin/sh

set -u

TEST_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd "$TEST_DIR/.." && pwd)
BIN_DIR="$ROOT_DIR/bin"

fail()
{
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

new_tmpdir()
{
    mktemp -d "${TMPDIR:-/tmp}/unix-toolbox.XXXXXX" || exit 1
}

skip_if_todo()
{
    program=$1
    source_file="$ROOT_DIR/$program/$program.c"

    if [ ! -f "$source_file" ]; then
        fail "$source_file is missing"
    fi
    if grep -q 'PROJECT_STATUS: TODO' "$source_file"; then
        printf 'SKIP: %s is still marked TODO\n' "$program"
        exit 77
    fi
}

require_binary()
{
    program=$1
    [ -x "$BIN_DIR/$program" ] || fail "$BIN_DIR/$program is not executable"
}

assert_files_equal()
{
    expected=$1
    actual=$2
    label=$3

    if ! cmp -s "$expected" "$actual"; then
        printf 'FAIL: %s\n' "$label" >&2
        printf '%s\n' '--- expected' >&2
        od -An -tx1c "$expected" >&2
        printf '%s\n' '--- actual' >&2
        od -An -tx1c "$actual" >&2
        exit 1
    fi
}

assert_nonzero()
{
    status=$1
    label=$2

    [ "$status" -ne 0 ] || fail "$label returned status 0"
}

assert_empty_file()
{
    file=$1
    label=$2

    [ ! -s "$file" ] || fail "$label was not empty"
}

assert_nonempty_file()
{
    file=$1
    label=$2

    [ -s "$file" ] || fail "$label was empty"
}

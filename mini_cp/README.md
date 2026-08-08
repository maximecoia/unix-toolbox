<div align="center">

# mini_cp

**A small regular-file copy utility in C built directly on Unix system calls.**

[![Status](https://img.shields.io/badge/status-complete-2ea44f.svg)](#verification)
[![C99](https://img.shields.io/badge/C-C99-00599C.svg)](https://en.wikipedia.org/wiki/C99)

[`source`](mini_cp.c) · [`tests`](../tests/test_mini_cp.sh) · [`repository`](../README.md)

</div>

---

## Overview

`mini_cp` is the third completed utility in `unix-toolbox`.

It reuses the buffered read/write loop from `mini_cat`, but changes the output side from standard output to a second file descriptor owned by the program.

The scope is intentionally smaller than the real Unix `cp`: this version copies one regular file to one destination path.

## Behavior

```text
usage: mini_cp source destination
```

The program:

- requires exactly one source and one destination;
- opens the source with `O_RDONLY`;
- identifies the source with `fstat()`;
- rejects non-regular sources before touching the destination;
- checks an existing destination with `stat()`;
- refuses to continue if source and destination resolve to the same device and inode;
- creates the destination when it does not exist;
- truncates an existing destination only after the safety checks succeed;
- copies bytes through a 1024-byte buffer;
- handles partial writes;
- retries interrupted `read()` and `write()` calls;
- returns non-zero on usage or I/O failure.

The destination is created with mode `0644`, subject to the process umask.

## Destructive-operation safety

`O_TRUNC` can destroy existing destination data immediately, so validation happens first.

The safe order is:

```text
open source
    |
    v
fstat source
    |
    +--> source is not regular? -> fail, destination untouched
    |
    v
stat destination
    |
    +--> same underlying file? -> fail, source untouched
    |
    v
open destination with O_TRUNC
    |
    v
copy
```

Same-file detection compares filesystem identity rather than pathname text:

```c
src_stat.st_dev == dst_stat.st_dev
&& src_stat.st_ino == dst_stat.st_ino
```

That catches aliases such as `data.txt`, `./data.txt`, and hard links.

Rejecting non-regular sources before `O_TRUNC` also prevents a directory source from causing an existing destination to be erased before `read()` fails.

## Copy loop

The outer loop owns input:

```text
read() > 0  -> copy this chunk
read() = 0  -> EOF, copy complete
read() < 0  -> retry EINTR or fail
```

Each successful `read()` produces exactly `bytes_read` valid bytes.

`write_all()` then guarantees that the whole chunk is written or reports failure.

## File-descriptor ownership

After successful destination open, the program owns two descriptors:

```text
source fd
destination fd
```

Every error path closes the descriptors that have already been acquired.

## Scope boundaries

This milestone does not implement:

- directory recursion;
- special-file copying;
- source permission/mode preservation;
- ownership preservation;
- timestamps;
- extended attributes;
- sparse-file optimization;
- atomic destination replacement;
- hardening against the race between `stat()` and destination `open()`;
- treating a `close()` failure as a copy failure.

## Verification

Build:

```sh
make mini_cp
```

Run:

```sh
sh tests/test_mini_cp.sh
```

The tests cover normal, empty, large and binary copies, destination truncation, invalid arguments and paths, same-file aliases, hard links, and the regression case where a directory source must leave an existing destination unchanged.

Expected result:

```text
PASS: mini_cp
```

## Takeaway

The main lesson is **resource ownership plus destructive-operation safety**: when `O_TRUNC` is involved, validation order is part of correctness.

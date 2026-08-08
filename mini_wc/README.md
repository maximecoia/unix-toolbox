<div align="center">

# mini_wc

**A small `wc`-like utility in C built around buffered input and persistent stream state.**

[![Status](https://img.shields.io/badge/status-complete-2ea44f.svg)](#verification)
[![C99](https://img.shields.io/badge/C-C99-00599C.svg)](https://en.wikipedia.org/wiki/C99)

[`source`](mini_wc.c) · [`tests`](../tests/test_mini_wc.sh) · [`repository`](../README.md)

</div>

---

## Overview

`mini_wc` is the fourth completed utility in `unix-toolbox` and closes the first project sequence.

Unlike `mini_cat` and `mini_cp`, the bytes are no longer merely transferred. Every byte can change program state.

This version accepts exactly one named file and prints line, word, and byte counts.

## Behavior

```text
usage: mini_wc file
```

Output:

```text
lines words bytes filename
```

The program:

- requires exactly one file operand;
- opens it read-only;
- reads through a 1024-byte buffer;
- counts every byte returned by `read()`;
- counts `'\n'` bytes as lines;
- counts words from transitions into non-whitespace text;
- preserves word state between separate `read()` calls;
- recognizes all six C whitespace characters used by `is_space()`;
- writes the counters and filename through checked `write()` calls;
- returns non-zero on invalid arguments, input failure, or output failure.

## Word-state machine

A new word is counted only when a non-whitespace byte is encountered while the program is outside a word:

```text
whitespace -> non-whitespace = words++
non-whitespace -> non-whitespace = same word
non-whitespace -> whitespace = leave word
```

`in_word` is initialized once for the complete stream, not once per buffer. A long word crossing a 1024-byte read boundary is therefore counted once.

## Output correctness

The final counters are emitted through the same checked-output principle used elsewhere in the project.

`write_all()`:

- handles partial writes;
- retries `EINTR`;
- reports failure if stdout cannot accept the result.

`putnbr()` propagates that failure through its recursive calls, and `print_result()` returns failure to `main()`.

This means `mini_wc` no longer reports success when its result cannot actually be written.

## Scope boundaries

This milestone does not implement:

- standard-input mode;
- several input files;
- aggregate `total` output;
- `-l`, `-w`, or `-c` flags;
- locale-aware character counting;
- locale-aware whitespace classification;
- detailed diagnostic messages.

## Verification

Build:

```sh
make mini_wc
```

Run:

```sh
sh tests/test_mini_wc.sh
```

The tests cover empty input, known counts, no final newline, all supported whitespace classes, words crossing buffer boundaries, filenames containing spaces, invalid arguments, missing files, and a closed-stdout regression proving output failures return non-zero.

Expected result:

```text
PASS: mini_wc
```

## Takeaway

The main lesson is the difference between **buffer-local data** and **stream-wide state**. The final output path now follows the same rule as the input path: system calls have results, and failures are propagated.

# mini_cat

Status: **not implemented yet**

The next project in `unix-toolbox`.

## Goal

Build a small `cat`-like program using `read()` and `write()`.

Planned behavior:

```text
usage: mini_cat [file ...]
```

- with no operands, read from standard input;
- with file operands, print each file in order;
- treat `-` as standard input;
- preserve bytes exactly;
- return non-zero on an I/O error;
- send diagnostics to standard error.

## What I expect to practise

- file descriptors;
- `open()`, `read()`, `write()`, and `close()`;
- fixed-size buffers;
- EOF versus read errors;
- writing only the bytes actually returned by `read()`;
- partial writes.

I will expand this README after implementing the project, based on the problems I actually run into.

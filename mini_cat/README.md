# mini_cat

> Status: **not implemented yet**

The next utility in `unix-toolbox`.

## Goal

Build a small `cat`-like program using `read()` and `write()`.

```text
usage: mini_cat [file ...]
```

Planned behavior:

- read from standard input when no file is provided;
- process file operands in order;
- treat `-` as standard input;
- preserve bytes exactly;
- return non-zero on an I/O error;
- send diagnostics to standard error.

## Focus

- file descriptors;
- `open()`, `read()`, `write()`, and `close()`;
- fixed-size buffers;
- EOF versus errors;
- writing only bytes returned by `read()`;
- partial writes.

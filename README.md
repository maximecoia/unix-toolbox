<div align="center">

# unix-toolbox

**Small Unix utilities rebuilt in C, one mechanism at a time.**

[![CI](https://github.com/maximecoia/unix-toolbox/actions/workflows/ci.yml/badge.svg)](https://github.com/maximecoia/unix-toolbox/actions/workflows/ci.yml)
[![C99](https://img.shields.io/badge/C-C99-00599C.svg)](https://en.wikipedia.org/wiki/C99)

`mini_echo` → `mini_cat` → `mini_cp` → `mini_wc`

</div>

---

## About

`unix-toolbox` is a small post-Piscine project built to deepen my understanding of C and Unix programming through progressively more demanding command-line utilities.

Each program keeps a deliberately limited scope so the implementation can be understood end to end: inputs, state, control flow, system calls, failure paths, and exact observable behavior.

The goal is not to clone the full GNU/BSD commands. It is to rebuild a focused subset of their behavior and understand the mechanisms underneath.

## Progress

| Command | Main focus | Status |
|---|---|---|
| [`mini_echo`](mini_echo/) | `argc`, `argv`, nested traversal, `write()` | **Complete** |
| [`mini_cat`](mini_cat/) | file descriptors, `read()`, buffers, EOF | Not started |
| [`mini_cp`](mini_cp/) | `open()`, copying, partial writes, cleanup | Not started |
| [`mini_wc`](mini_wc/) | counters and stream state | Not started |

## Progression

```mermaid
flowchart LR
    E[mini_echo<br/>arguments + write]
    C[mini_cat<br/>read + buffers]
    P[mini_cp<br/>open + copy]
    W[mini_wc<br/>state + counters]

    E --> C --> P --> W
```

Each step reuses part of the previous one and adds a new problem.

## Current milestone

### mini_echo

The first completed utility reproduces a deliberately small subset of `echo`:

```sh
./bin/mini_echo hello unix
# hello unix
```

It focuses on:

- argument traversal with `argc` and `argv`;
- nested loops over operands and characters;
- separator placement;
- byte-oriented output with `write()`;
- output failure handling;
- process exit status.

Implementation notes and tests: [`mini_echo/README.md`](mini_echo/README.md)

## Build

Requirements:

- a C99-compatible compiler;
- `make`;
- a POSIX-compatible shell.

Build all utilities:

```sh
make
```

Build one utility:

```sh
make mini_echo
```

Binaries are written to `bin/`.

## Test

Run all active suites:

```sh
make test
```

Compile and test:

```sh
make check
```

Run one suite directly:

```sh
sh tests/test_mini_echo.sh
```

Unfinished commands keep the marker:

```c
/* PROJECT_STATUS: TODO */
```

Their suites are skipped until the implementation is activated.

## Repository structure

```text
unix-toolbox/
├── mini_echo/
│   ├── README.md
│   └── mini_echo.c
├── mini_cat/
├── mini_cp/
├── mini_wc/
├── tests/
├── docs/
├── .github/workflows/ci.yml
├── Makefile
└── README.md
```

## Project rules

- keep each utility small enough to understand end to end;
- derive control flow from required behavior rather than from remembered code;
- check system calls instead of assuming success;
- test exact output, stderr, and exit status;
- add abstractions only when they solve a real problem.

## Roadmap

The next utility is [`mini_cat`](mini_cat/).

A short progression overview is available in [`docs/roadmap.md`](docs/roadmap.md).

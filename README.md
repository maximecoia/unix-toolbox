# unix-toolbox

[![CI](https://github.com/maximecoia/unix-toolbox/actions/workflows/ci.yml/badge.svg)](https://github.com/maximecoia/unix-toolbox/actions/workflows/ci.yml)

I started this repository after the 42 Piscine because I noticed a gap between **recognizing C patterns** and being able to rebuild them from an empty file.

The idea is simple: recreate a few small Unix commands in increasing difficulty and use them to practise turning a subject into variables, loops, system calls, error paths, and working C.

This is not an attempt to clone the full GNU/BSD tools. Each program intentionally implements a small contract that I can understand and explain end to end.

## Progress

| Command | Main focus | Status |
|---|---|---|
| [`mini_echo`](mini_echo/) | `argc`, `argv`, nested loops, `write()` | **Complete** |
| [`mini_cat`](mini_cat/) | file descriptors, `read()`, buffers, EOF | Not started |
| [`mini_cp`](mini_cp/) | `open()`, copying, partial writes, cleanup | Not started |
| [`mini_wc`](mini_wc/) | counters and stream state | Not started |

Planned order:

```text
mini_echo -> mini_cat -> mini_cp -> mini_wc
```

The order matters because each project reuses part of the previous one and adds a new problem.

## Build

Requirements:

- a C99 compiler;
- `make`;
- a POSIX-compatible shell.

Build everything:

```sh
make
```

Build one command:

```sh
make mini_echo
```

Binaries are written to `bin/`.

## Tests

Run the active test suites:

```sh
make test
```

Or compile and test in one step:

```sh
make check
```

Run one suite directly:

```sh
sh tests/test_mini_echo.sh
```

A project that still contains:

```c
/* PROJECT_STATUS: TODO */
```

is treated as unfinished and its suite is skipped.

## Current milestone: mini_echo

`mini_echo` was the first project I completed.

```sh
./bin/mini_echo hello unix
# hello unix
```

It looks trivial, but it was useful for practising:

- `argc` and `argv`;
- the difference between `argv[i]` and `argv[i][j]`;
- nested loops;
- empty string arguments;
- separator placement;
- passing an address to `write()`;
- checking a system call's return value;
- returning the correct process exit status.

The project page includes the implementation notes and the mistakes I made while building it:

[`mini_echo/README.md`](mini_echo/README.md)

## Repository structure

```text
unix-toolbox/
├── mini_echo/
├── mini_cat/
├── mini_cp/
├── mini_wc/
├── tests/
├── docs/
├── Makefile
└── README.md
```

## Ground rules

For these projects I try to keep a few rules:

- start from the written behavior, not from remembered code;
- keep implementations small until there is a real reason to split them;
- check system calls instead of assuming they succeeded;
- use tests to inspect exact behavior, especially output bytes and exit status;
- after finishing a project, try to reconstruct it again from a blank file.

## Roadmap

A short roadmap is available in [`docs/roadmap.md`](docs/roadmap.md).

The next project is [`mini_cat`](mini_cat/).

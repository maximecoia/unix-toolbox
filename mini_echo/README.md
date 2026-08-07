<div align="center">

# mini_echo

**Rebuilding the essential behavior of `echo` from first principles in C.**

[![Status](https://img.shields.io/badge/status-complete-2ea44f.svg)](#verification)
[![Language](https://img.shields.io/badge/language-C99-00599C.svg)](https://en.wikipedia.org/wiki/C99)
[![I/O](https://img.shields.io/badge/I%2FO-POSIX%20write()-333333.svg)](https://pubs.opengroup.org/onlinepubs/9699919799/functions/write.html)
[![Tests](https://img.shields.io/badge/tests-PASS-2ea44f.svg)](../tests/test_mini_echo.sh)
[![Milestone](https://img.shields.io/badge/unix--toolbox-1%20%2F%204-f59e0b.svg)](../README.md)

[`source`](mini_echo.c) · [`tests`](../tests/test_mini_echo.sh) · [`unix-toolbox`](../README.md)

</div>

---

## Overview

`mini_echo` is the first completed milestone of [`unix-toolbox`](../README.md), a progression of small Unix utilities rebuilt in C.

The program is intentionally much smaller than a production `echo`. The objective is to understand the mechanisms beneath the command:

- command-line arguments with `argc` and `argv`;
- nested traversal of arguments and characters;
- C string termination with `\0`;
- exact separator placement;
- byte-oriented output with `write()`;
- system-call return-value checking;
- Unix exit statuses.

```text
usage: mini_echo [operand ...]
```

### Contract

`mini_echo`:

- prints every operand in its original order;
- places exactly one ASCII space between adjacent operands;
- prints no leading or trailing separator;
- finishes with exactly one newline;
- treats arguments beginning with `-` as ordinary data;
- prints only a newline when no operand is supplied;
- returns `0` on success;
- returns non-zero if an output operation fails.

No option parsing. No allocation. No string-library helpers.

---

## Quick demo

```sh
$ ./bin/mini_echo hello
hello

$ ./bin/mini_echo hello unix world
hello unix world

$ ./bin/mini_echo "hello world" "" tail
hello world  tail

$ ./bin/mini_echo -n hello
-n hello
```

The empty operand in the third example is significant:

```text
"hello world" + separator + "" + separator + "tail"

hello world[space][space]tail
```

`-n` is deliberately treated as an ordinary operand rather than an option.

---

## Architecture

The implementation has two traversal levels:

```mermaid
flowchart TD
    A[Start] --> B[i = 1]
    B --> C{i < argc?}

    C -- No --> N[write newline]
    N --> O{write returned 1?}
    O -- No --> F[return non-zero]
    O -- Yes --> S[return 0]

    C -- Yes --> D{i > 1?}
    D -- Yes --> E[write separator]
    E --> E2{write returned 1?}
    E2 -- No --> F
    E2 -- Yes --> G[j = 0]
    D -- No --> G

    G --> H{argv[i][j] != '\0'?}
    H -- Yes --> I[write current character]
    I --> I2{write returned 1?}
    I2 -- No --> F
    I2 -- Yes --> J[j++]
    J --> H

    H -- No --> K[i++]
    K --> C
```

The important hierarchy is:

```text
PROGRAM
│
├── operand loop        → i
│   │
│   ├── separator decision
│   ├── reset j
│   │
│   └── character loop  → j
│
├── final newline
└── final exit status
```

---

## How it works

### 1. `argc` and `argv`

For:

```sh
./bin/mini_echo hello unix
```

`main` conceptually receives:

```text
argc = 3

argv[0] = "./bin/mini_echo"
argv[1] = "hello"
argv[2] = "unix"
argv[3] = NULL
```

The key boundaries are:

```text
argv[0]          program name
argv[1]          first operand
argv[argc - 1]   last argument
argv[argc]       NULL
```

That is why operand traversal begins at index `1` and continues only while the index is strictly below `argc`.

### 2. Two indexes, two responsibilities

The implementation only needs two pieces of changing state:

```text
i → current operand
j → current character inside that operand
```

The distinction is visible in:

```c
argv[i]       /* one complete argument */
argv[i][j]    /* one character inside that argument */
```

`i` advances after a complete operand.

`j` advances after a complete character.

### 3. C strings stop at `\0`

An argument such as `"cat"` is stored conceptually as:

```text
index   0     1     2      3
      +-----+-----+-----+------+
      | 'c' | 'a' | 't' | '\0' |
      +-----+-----+-----+------+
```

The inner loop continues while:

```c
argv[i][j] != '\0'
```

The terminating byte is **checked**, but never printed.

An empty string contains no visible characters:

```text
argv[i][0] = '\0'
```

so its inner loop executes zero times.

It still remains a real operand at the outer-loop level.

### 4. Why `j` resets

Every operand is a separate C string.

After traversing `"hello"`, `j` has reached the end of that string. The next argument must start again from its own character `0`.

```text
argv[1] → h e l l o \0
          0 1 2 3 4

argv[2] → u n i x \0
          0 1 2 3
```

Therefore `j = 0` belongs inside the operand loop.

### 5. Separator strategy

The rule is:

> Print one space **before every operand except the first**.

```text
operand 1 → A
operand 2 → [space]B
operand 3 → [space]C
```

Result:

```text
A B C
```

This naturally guarantees:

- no leading space;
- no trailing space;
- exactly one separator per adjacent operand pair.

It also handles empty strings without special cases.

For:

```sh
./bin/mini_echo "" A ""
```

the exact output is:

```text
[space]A[space]\n
```

### 6. `write()` works with bytes

Output is produced with the POSIX system call:

```c
write(fd, buffer, count)
```

For this project:

```text
fd    = 1      → standard output
count = 1      → one byte at a time
```

For a character inside `argv`, `write()` needs its address:

```c
&argv[i][j]
```

not merely the character value itself.

### 7. Output failure propagates to `main`

Every required output operation is checked:

```text
separator
character
newline
```

For a one-byte operation:

```text
write() returns 1
→ that byte was successfully written
```

Anything else is treated as failure and terminates the program with a non-zero status.

The two return conventions are different:

```text
write() returning 1
→ one output operation succeeded

main() returning 0
→ the entire program succeeded
```

The program only reaches `return 0` after all required output, including the final newline, has succeeded.

---

## Edge cases

| Invocation | Exact conceptual output |
|---|---|
| `./bin/mini_echo` | `\n` |
| `./bin/mini_echo hello` | `hello\n` |
| `./bin/mini_echo A B` | `A[space]B\n` |
| `./bin/mini_echo "" ""` | `[space]\n` |
| `./bin/mini_echo "" A ""` | `[space]A[space]\n` |
| `./bin/mini_echo "hello world" tail` | `hello world[space]tail\n` |
| `./bin/mini_echo -n hello` | `-n[space]hello\n` |

The implementation needs no dedicated branches for empty strings or the zero-operand case. Correct loop boundaries handle both naturally.

---

## Debugging invariants

The implementation can be checked against a small set of rules:

```text
i starts at 1
i remains strictly below argc
j resets to 0 for every operand
j advances inside the character loop
i advances after the character loop
spaces are decided at operand level
'\0' is checked but not written
newline is written once, after all operands
every write() result is checked
success from main is 0
```

These invariants are more useful than memorizing the finished source.

---

## Verification

Build from the repository root:

```sh
make mini_echo
```

Compilation uses:

```text
-Wall -Wextra -Werror -std=c99
```

Run the dedicated test suite:

```sh
sh tests/test_mini_echo.sh
```

Verified result:

```text
PASS: mini_echo
```

The suite verifies:

- zero operands;
- one operand;
- multiple operands;
- embedded spaces;
- empty operands;
- dash-prefixed operands;
- exact standard-output bytes;
- successful execution without unwanted standard-error output where asserted.

For manual byte-level inspection:

```sh
./bin/mini_echo "hello world" "" tail | cat -e
```

produces:

```text
hello world  tail$
```

The `$` is displayed by `cat -e` to make the final newline visible.

---

## What this milestone trained

The main result of `mini_echo` is not the number of lines of C. It is the reconstruction process:

```text
written subject
      ↓
inputs / outputs
      ↓
state variables
      ↓
repetitions
      ↓
stopping conditions
      ↓
conditional actions
      ↓
failure paths
      ↓
pseudocode
      ↓
C
      ↓
compile + trace + test
```

The project connected several foundational C and Unix concepts:

- `argc`, `argv`, `char **`;
- indexes and nested loops;
- C string termination;
- addresses and characters;
- file descriptors;
- `write()`;
- checked system-call results;
- exact byte-oriented output;
- process exit status;
- edge-case reasoning.

The important shift is from **recognizing a familiar solution** to **deriving the implementation from the contract**.

---

## Next milestone — `mini_cat`

`mini_echo` traverses data that already exists in `argv`.

The next project introduces input from a byte stream:

```text
mini_echo
argv
  ↓
characters
  ↓
write()
```

becomes:

```text
mini_cat
file descriptor
  ↓
read()
  ↓
buffer
  ↓
write()
  ↓
repeat until EOF
```

Continue with [`mini_cat`](../mini_cat/).

---

<div align="center">

**Milestone 1 / 4 complete**

`mini_echo` → **`mini_cat`** → `mini_cp` → `mini_wc`

</div>

# mini_echo

A small version of `echo`, written in C with `write()`.

This was the first project in `unix-toolbox` and the main goal was not the command itself. I used it to practise rebuilding a program from a short subject instead of relying on recognition from previous exercises.

## Behavior

```text
usage: mini_echo [operand ...]
```

The program:

- prints operands in their original order;
- puts one space between adjacent operands;
- prints no leading or trailing separator;
- always ends with one newline;
- treats `-n` and other dash-prefixed arguments as ordinary text;
- prints only a newline when there are no operands;
- returns non-zero if output fails.

Examples:

```sh
./bin/mini_echo hello
# hello

./bin/mini_echo hello unix world
# hello unix world

./bin/mini_echo "hello world" "" tail
# hello world  tail

./bin/mini_echo -n hello
# -n hello
```

## Implementation

The implementation is intentionally kept in one file.

The outer loop walks through the operands:

```c
i = 1;
while (i < argc)
```

`argv[0]` is the program name, so the first operand is `argv[1]`.

Inside that loop, `j` walks through the current string until `\0`:

```c
j = 0;
while (argv[i][j] != '\0')
```

I print a space **before every operand except the first**. That made the separator rule easier to reason about because it avoids a trailing-space special case.

Every output is a one-byte `write()` and every call is checked.

## What tripped me up

These were the useful mistakes in this project.

### I put `i++` in the wrong block

My first version incremented `i` only inside the separator condition:

```text
if i > 1
    print space
    i++
```

For the first operand, `i > 1` is false, so `i` never changed. The outer loop kept processing the same argument forever.

The rule I kept from that bug is:

```text
j advances after one character
i advances after one complete operand
```

### I initially ignored `write()` results

The output looked simple enough that my first instinct was just to call `write()`.

But the project contract says output failure must make the program fail, so the separator, each character, and the final newline all need their return values checked.

### `write()` success is not `main()` success

For a one-byte write:

```text
write() returns 1 -> that byte was written
```

But for the program:

```text
main() returns 0 -> the program succeeded
```

I initially had to stop and separate those two conventions.

### I ran an old binary once

At one point the source had changed but the executable still printed the starter message.

The issue was simply that I had not rebuilt the executable I was running.

That made this workflow much more concrete:

```text
edit source -> compile -> run executable
```

## Tests

Build and run the dedicated suite from the repository root:

```sh
make mini_echo
sh tests/test_mini_echo.sh
```

Current result:

```text
PASS: mini_echo
```

The tests cover:

- zero operands;
- one operand;
- several operands;
- an argument containing spaces;
- an empty argument;
- a dash-prefixed argument;
- exact stdout;
- empty stderr on the basic successful cases.

For checking invisible spaces and the final newline manually, I also used:

```sh
./bin/mini_echo "" A "" | cat -e
```

which should show:

```text
 A $
```

## What I want to retain

From this project, the part I care about remembering is the structure:

```text
arguments
    -> characters
        -> write one byte
```

and the habit of deriving:

```text
input -> state -> loop -> stopping condition -> update -> failure path
```

instead of trying to remember the finished source.

Next: [`mini_cat`](../mini_cat/), where the input moves from `argv` strings to file descriptors and `read()`.

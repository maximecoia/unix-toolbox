# mini_echo

## Objective

Rebuild the essential behavior of `echo` without option parsing.

This first command trains the translation of a tiny written subject into indexes, repetitions, separators, and stopping conditions.

## Contract

```text
usage: mini_echo [operand ...]
```

- Print every operand in its original order.
- Put exactly one ASCII space between adjacent operands.
- Print no leading or trailing space.
- Finish with exactly one newline.
- Treat strings beginning with `-` as ordinary operands.
- With no operands, print only a newline.
- Return `0` on success and a non-zero status if output fails.

## Examples

```sh
./bin/mini_echo

./bin/mini_echo hello
# hello

./bin/mini_echo hello unix world
# hello unix world

./bin/mini_echo -n hello
# -n hello
```

## Mechanisms to practise

- `argc` and `argv`;
- `char **` and string traversal;
- outer repetition over arguments;
- inner repetition over characters;
- separator placement;
- `write()` and return-value checking.

## Deliberate limitations

- no `-n` option;
- no escape-sequence interpretation;
- no environment expansion;
- no allocation.

## Blank-page worksheet

Before writing C, answer these questions in comments or on paper:

1. What is the first operand index?
2. What condition means that every operand has been processed?
3. What condition means that every character of one operand has been processed?
4. When should a separator be printed?
5. Which output operations can fail?
6. What exit status represents success?

## Edge cases

- zero operands;
- one operand;
- several operands;
- an empty string operand;
- an operand containing spaces;
- an operand beginning with `-`.

## Definition of done

- [ ] The `PROJECT_STATUS: TODO` marker has been removed.
- [ ] The program compiles with `-Wall -Wextra -Werror -std=c99`.
- [ ] No output is sent to standard error during successful execution.
- [ ] `sh tests/test_mini_echo.sh` reports `PASS`.
- [ ] The code can be explained without reading comments.

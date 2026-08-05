# mini_cat

## Objective

Copy byte streams to standard output using a fixed-size buffer.

This command introduces the central Unix I/O loop: request bytes, process the returned byte count, and stop at end-of-file.

## Contract

```text
usage: mini_cat [file ...]
```

- With no operands, copy standard input to standard output.
- With file operands, copy each file in order.
- Treat the operand `-` as standard input.
- Preserve every byte exactly, including `\0` and non-text bytes.
- Stop and return non-zero after an input or output error.
- Send diagnostics to standard error.
- Support no options.

## Examples

```sh
./bin/mini_cat notes.txt
./bin/mini_cat chapter-1.txt chapter-2.txt
printf 'hello\n' | ./bin/mini_cat
printf 'middle\n' | ./bin/mini_cat first.txt - last.txt
```

## Mechanisms to practise

- standard file descriptors `0`, `1`, and `2`;
- `open()`, `read()`, `write()`, and `close()`;
- fixed-size `char` buffers;
- byte counts returned by `read()`;
- end-of-file versus error;
- repeated writes when one `write()` consumes only part of a buffer;
- cleanup after failure.

## Deliberate limitations

- no line numbering;
- no visible-control-character mode;
- no option parser;
- no directory support;
- no dynamic allocation.

## Blank-page worksheet

1. Which descriptor represents standard input?
2. Which descriptor represents standard output?
3. What are the three meanings of a `read()` return value?
4. Which number, rather than the buffer capacity, must be passed to `write()`?
5. How will the program finish writing if `write()` writes only part of the requested bytes?
6. Which descriptors belong to the program and therefore need closing?
7. How does `-` change the selected input descriptor?

## Edge cases

- empty standard input;
- empty files;
- several files;
- `-` between two files;
- binary bytes;
- a missing or unreadable file;
- a failed write to standard output.

## Definition of done

- [ ] The `PROJECT_STATUS: TODO` marker has been removed.
- [ ] The implementation is binary-safe.
- [ ] Every `open()`, `read()`, `write()`, and owned `close()` is checked.
- [ ] `sh tests/test_mini_cat.sh` reports `PASS`.
- [ ] The buffer loop and partial-write loop can be reconstructed from memory.

# mini_wc

## Objective

Count lines, words, and bytes while reading a stream incrementally.

This command adds a small state machine to the buffered I/O pattern. The current byte and the previous in-word state determine whether the word count changes.

## Contract

```text
usage: mini_wc [file ...]
```

- With no operands, read standard input.
- Otherwise process every file in order.
- For standard input, print:

```text
lines words bytes
```

- For a named file, print:

```text
lines words bytes filename
```

- Separate fields with one ASCII space and end each record with one newline.
- Do not align or pad columns.
- Do not print an aggregate `total` line.
- Count bytes, not Unicode characters.
- Count a line for every `\n` byte.
- Define a word as a maximal sequence of bytes that are not ASCII whitespace.
- ASCII whitespace is: space, tab, newline, carriage return, vertical tab, or form feed.
- Return non-zero after an input, output, or close error.

## Examples

```sh
printf 'hello world\n' | ./bin/mini_wc
# 1 2 12

./bin/mini_wc notes.txt
# 12 84 531 notes.txt
```

## Mechanisms to practise

- all buffered I/O mechanisms from `mini_cat`;
- integer counters;
- traversing only the bytes returned by `read()`;
- state carried across buffer boundaries;
- whitespace classification;
- integer-to-decimal output without `printf()` if you choose a system-call-only implementation;
- one-file-at-a-time state reset.

## Deliberate limitations

- no `-l`, `-w`, `-c`, or `-m` flags;
- no padded columns;
- no aggregate total;
- no locale-aware word definition;
- no Unicode character counting.

## Blank-page worksheet

1. Which three counters are required?
2. Which Boolean state distinguishes being inside and outside a word?
3. Which byte increments the line counter?
4. Which transition increments the word counter?
5. Which state must survive when a word crosses two `read()` buffers?
6. When must all counters and state be reset?
7. How will non-negative integer counts be printed?

## Edge cases

- empty input;
- input containing only whitespace;
- one word without a final newline;
- several adjacent whitespace characters;
- a word split across two reads;
- several files;
- a missing file;
- binary bytes that are not ASCII whitespace.

## Definition of done

- [ ] The `PROJECT_STATUS: TODO` marker has been removed.
- [ ] Empty input produces `0 0 0`.
- [ ] Word state survives buffer boundaries.
- [ ] Counters reset between files.
- [ ] `sh tests/test_mini_wc.sh` reports `PASS`.
- [ ] The word-count state machine can be explained with two states and two transitions.

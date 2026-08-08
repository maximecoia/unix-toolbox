# Roadmap

The projects are ordered so that each one reuses something from the previous project and introduces one new problem.

## 1. mini_echo — complete

Main ideas:

- `argc` / `argv`;
- nested traversal;
- C strings;
- separator placement;
- checked `write()` calls.

Current status: `PASS: mini_echo`.

## 2. mini_cat — complete

Move from strings already present in memory to bytes coming from a file descriptor.

Main ideas:

- `open()` and file descriptors;
- `read()`;
- fixed-size buffers;
- EOF versus errors;
- writing only the bytes returned by `read()`;
- partial writes;
- descriptor cleanup.

Current scope:

```text
mini_cat file
```

Current status: `PASS: mini_cat`.

## 3. mini_cp — complete

Reuse the stream-copy loop and add an explicit destination.

Main ideas:

- separate source and destination descriptors;
- `O_CREAT` and `O_TRUNC`;
- 1024-byte buffered copying;
- a reusable partial-write loop;
- cleanup with multiple owned descriptors;
- checking file identity with device and inode metadata;
- preventing same-file truncation before opening the destination destructively.

Current scope:

```text
mini_cp source destination
```

Current status: `PASS: mini_cp`.

## 4. mini_wc — complete

Reuse buffered input and change the problem from transporting bytes to interpreting a stream.

Main ideas:

- independent line, word, and byte counters;
- byte counts derived directly from `read()`;
- newline counting;
- explicit whitespace classification;
- an `in_word` state machine;
- state surviving between 1024-byte buffer reads;
- manual decimal output with recursive `putnbr()`.

Current scope:

```text
mini_wc file
```

Current status: `PASS: mini_wc`.

## Finish line — reached

The first `unix-toolbox` sequence is complete:

```text
mini_echo
   ↓
mini_cat
   ↓
mini_cp
   ↓
mini_wc
```

Across the four utilities, the progression moved from argument traversal to file descriptors, buffered I/O, multiple-resource ownership, and finally stream-wide state.

The repository's first version now has all four planned commands implemented and tested.

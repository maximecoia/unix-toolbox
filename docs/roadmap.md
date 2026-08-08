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

## 4. mini_wc — next

Reuse buffered input and add state that changes while bytes are processed.

Main new ideas:

- counters;
- word-boundary state;
- state surviving between buffer reads;
- number formatting.

## Finish line

The first version of this repository is done when all four commands are implemented, their tests pass, and I can explain/rebuild the important control flow without depending on the old source.

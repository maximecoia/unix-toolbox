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

## 2. mini_cat — next

Move from strings already present in memory to input streams.

Main new ideas:

- file descriptors;
- `read()`;
- fixed-size buffers;
- EOF;
- partial writes.

## 3. mini_cp

Reuse the stream-copy loop and add an explicit destination.

Main new ideas:

- `open()` flags;
- creating/truncating files;
- owning more than one descriptor;
- cleanup after failures.

## 4. mini_wc

Reuse buffered input and add state that changes while bytes are processed.

Main new ideas:

- counters;
- word-boundary state;
- state surviving between buffer reads;
- number formatting.

## Finish line

The first version of this repository is done when all four commands are implemented, their tests pass, and I can explain/rebuild the important control flow without depending on the old source.

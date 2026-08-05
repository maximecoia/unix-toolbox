# Roadmap

The order is intentional. Each command reuses the previous command's mechanisms and adds one new problem.

## Milestone 0 — Repository baseline

**Deliverable:** documentation, starters, build system, and test harness compile cleanly.

Completion gate:

```sh
make check
```

Expected initial result: four compiled starters, four skipped suites, zero failures.

Suggested commit:

```text
docs: initialize unix-toolbox roadmap and test harness
```

## Milestone 1 — mini_echo

**New mechanisms:** `argc`, `argv`, nested traversal, and separator placement.

Completion gate:

- remove the TODO marker;
- pass `sh tests/test_mini_echo.sh`;
- explain why separators are printed between arguments rather than after every argument;
- reconstruct the implementation from a blank file on a later day.

Suggested commits:

```text
test(echo): activate command behavior checks
feat(echo): implement operand output
```

## Milestone 2 — mini_cat

**New mechanisms:** file descriptors, buffered `read()`/`write()`, end-of-file, and partial writes.

Completion gate:

- pass standard-input, multi-file, dash-operand, empty-file, and binary tests;
- distinguish `read() == 0` from `read() == -1`;
- explain why `write()` receives the byte count returned by `read()`;
- redraw both the read loop and the partial-write loop.

Suggested commits:

```text
test(cat): activate stream-copy cases
feat(cat): copy stdin and file operands
fix(cat): complete partial writes
```

## Milestone 3 — mini_cp

**New mechanisms:** source/destination ownership, open flags, destination creation, truncation, and cleanup paths.

Completion gate:

- pass empty, text, binary, overwrite, usage, and missing-source tests;
- close every descriptor owned by the process;
- explain `O_CREAT`, `O_TRUNC`, and the requested `0644` mode;
- reconstruct the descriptor lifecycle before writing the copy loop.

Suggested commits:

```text
test(cp): activate file-copy cases
feat(cp): copy one file to another
fix(cp): close descriptors on every failure path
```

## Milestone 4 — mini_wc

**New mechanisms:** counters and a state machine that survives buffer boundaries.

Completion gate:

- pass exact line, word, byte, formatting, multi-file, and missing-file tests;
- explain the two states "inside a word" and "outside a word";
- identify the transition that increments the word count;
- demonstrate that a word split across two buffers is still counted once.

Suggested commits:

```text
test(wc): activate stream-counting cases
feat(wc): count lines words and bytes
fix(wc): preserve word state across reads
```

## Milestone 5 — Review release

Before tagging `v1.0.0`:

- every status is `ACTIVE`;
- `make check` passes on Linux and macOS CI;
- README status entries are updated;
- no debug prints remain;
- every error path returns non-zero;
- each command has been reconstructed cold at least once;
- limitations match the actual behavior.

A reasonable first release contains only the four promised commands. Add future utilities in later releases, not before the initial learning loop is complete.

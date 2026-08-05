# Concept map

## Progression overview

| Mechanism | echo | cat | cp | wc |
|---|:---:|:---:|:---:|:---:|
| `argc` / `argv` | Core | Core | Core | Core |
| String traversal | Core | — | — | Filename only |
| Nested loops | Core | Partial writes | Partial writes | Buffer traversal |
| Standard file descriptors | Output | Input/output | Diagnostics | Input/output |
| `open()` / `close()` | — | Files | Source + destination | Files |
| `read()` / fixed buffer | — | Core | Core | Core |
| Partial writes | Useful | Required | Required | Output dependent |
| Error cleanup | Basic | Required | Core | Required |
| Stream state | — | EOF | Copy progress | Word state |
| Counters | Indexes | Byte offsets | Byte offsets | Lines/words/bytes |

## Control flow

Every utility can be described with the same questions:

1. What state exists before a loop starts?
2. What condition keeps the loop running?
3. What changes during one iteration?
4. What condition stops the loop successfully?
5. What failures stop the loop unsuccessfully?

For file I/O, never collapse end-of-file and error into one case:

- positive `read()` result: bytes are available;
- zero: end-of-file;
- negative: error.

## Arguments and pointers

In `main(int argc, char **argv)`:

- `argc` is the number of argument strings;
- `argv` points to an array of pointers;
- `argv[i]` is one argument string;
- `argv[i][j]` is one character inside that string.

`mini_echo` makes both indexes visible. The other commands mostly use `argv[i]` as a pathname passed to `open()`.

## File descriptors

A file descriptor is a small integer used by the process to refer to an open I/O resource.

Conventional descriptors are:

- `0`: standard input;
- `1`: standard output;
- `2`: standard error.

A descriptor returned by `open()` is owned by the process and should be closed. Standard descriptors are normally borrowed rather than closed by these small programs.

## Buffers

A fixed-size buffer separates the amount requested from the amount actually received.

```text
buffer capacity       maximum bytes one read may return
read return value     bytes valid during this iteration
```

Only the first `bytes_read` positions contain current input. Writing the full capacity can leak stale or uninitialized bytes.

## Partial writes

A successful `write()` may consume fewer bytes than requested. Correct code therefore tracks:

- total bytes that must be written;
- bytes already written;
- address of the first unwritten byte;
- remaining byte count.

This inner loop is reusable in `mini_cat` and `mini_cp`.

## Ownership and cleanup

For every descriptor, decide:

- who opened it;
- who closes it;
- what happens if the next operation fails;
- whether a later error must preserve an earlier error status.

`mini_cp` is the first utility where two owned descriptors can be open simultaneously, making cleanup design more important than the central copy loop.

## Word-count state machine

`mini_wc` needs two states:

```text
OUTSIDE_WORD
INSIDE_WORD
```

A word begins only when the input transitions from whitespace to non-whitespace. The state must survive between buffer reads; resetting it per buffer would double-count a word split at a buffer boundary.

## Exit statuses and streams

Use standard output for the command's data and standard error for diagnostics.

A conventional contract for this project is:

- `0`: successful completion;
- non-zero: invalid usage or runtime failure.

Tests should validate both content and status. Correct text with an incorrect status is still incorrect command behavior.

# mini_cp

## Objective

Copy one file into another with explicit source and destination file descriptors.

`mini_cp` extends the stream-copying mechanism from `mini_cat` by adding destination creation, truncation, ownership, cleanup, and stricter argument validation.

## Contract

```text
usage: mini_cp source destination
```

- Require exactly two operands.
- Open the source for reading.
- Create the destination when it does not exist.
- Truncate the destination when it already exists.
- Request destination mode `0644`, subject to the process umask.
- Preserve the source bytes exactly.
- Correctly handle partial writes.
- Return non-zero after usage, open, read, write, or close failures.
- Send diagnostics to standard error.

## Examples

```sh
./bin/mini_cp source.txt destination.txt
cmp source.txt destination.txt
```

## Mechanisms to practise

- exact `argc` validation;
- read-only and write-only `open()` flags;
- `O_CREAT` and `O_TRUNC`;
- mode arguments and the process umask;
- ownership of two descriptors;
- binary-safe buffer copying;
- partial writes;
- cleanup paths and exit statuses.

## Deliberate limitations

- no recursive copies;
- no directory copying;
- no metadata, timestamp, ownership, or extended-attribute preservation;
- no overwrite confirmation;
- no symbolic-link policy;
- no sparse-file optimization.

## Blank-page worksheet

1. Which exact `argc` value represents valid usage?
2. Which flags belong to the source and destination?
3. At which points can the program fail before copying starts?
4. What state is required by the outer read loop?
5. What state is required by the inner partial-write loop?
6. Which descriptors need closing on every exit path?
7. What happens when the source and destination refer to the same file?

The final question is intentionally outside the mandatory contract. Record the behavior you observe and decide later whether to add protection.

## Edge cases

- empty source;
- ordinary text;
- embedded zero bytes;
- destination already containing longer data;
- missing source;
- invalid argument count;
- unwritable destination;
- output failure after a successful open.

## Definition of done

- [ ] The `PROJECT_STATUS: TODO` marker has been removed.
- [ ] The program never writes uninitialized buffer bytes.
- [ ] The destination is truncated correctly.
- [ ] Every owned descriptor is closed.
- [ ] `sh tests/test_mini_cp.sh` reports `PASS`.
- [ ] The copy loop can be redrawn as a control-flow diagram from memory.

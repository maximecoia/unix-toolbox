# mini_cp

> Status: **not implemented yet**

A small file-copy utility that builds on the stream-copying work from `mini_cat`.

## Goal

```text
usage: mini_cp source destination
```

Planned behavior:

- require one source and one destination;
- open the source for reading;
- create or truncate the destination;
- preserve source bytes exactly;
- handle partial writes;
- return non-zero on usage or I/O failure.

## Focus

- `open()` flags;
- file descriptor ownership;
- `O_CREAT` and `O_TRUNC`;
- source/destination cleanup;
- binary-safe copying;
- partial writes.

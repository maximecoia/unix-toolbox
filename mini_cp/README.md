# mini_cp

Status: **not implemented yet**

A small file-copy project that will build on `mini_cat`.

## Goal

```text
usage: mini_cp source destination
```

Planned behavior:

- require one source and one destination;
- open the source for reading;
- create or truncate the destination;
- copy the source bytes exactly;
- handle partial writes;
- return non-zero on usage or I/O failure.

## What I expect to practise

- `open()` flags;
- file descriptor ownership;
- `O_CREAT` and `O_TRUNC`;
- source/destination cleanup;
- binary-safe copying;
- partial writes.

I will document the actual implementation decisions and mistakes after the project is complete.

# mini_wc

> Status: **not implemented yet**

The last planned utility in the first `unix-toolbox` sequence.

## Goal

Count lines, words, and bytes while reading a stream.

Standard-input output:

```text
lines words bytes
```

Named-file output:

```text
lines words bytes filename
```

## Focus

- buffered input;
- counters;
- state carried between reads;
- word-boundary detection;
- integer output;
- state reset between files.

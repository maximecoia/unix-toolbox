# Reconstruction workflow

This workflow is designed for blank-page practice. It deliberately separates understanding from implementation.

## 1. Rewrite the contract

Without writing C, state:

- valid inputs;
- exact output format;
- success status;
- failure cases;
- explicit limitations.

Ambiguous behavior should be decided before the first loop is written.

## 2. Identify state

List only the variables the program must remember.

Typical categories:

- argument index;
- character or buffer index;
- file descriptors;
- buffer;
- byte count returned by `read()`;
- bytes already written;
- counters;
- inside/outside-word state;
- final exit status.

For every variable, write its initial value and why it changes.

## 3. Draw descriptor ownership

For commands that open files, draw the lifecycle before coding:

```text
open source
    ↓ success
open destination
    ↓ success
copy loop
    ↓
close destination
    ↓
close source
```

Add every failure arrow and the resources that still require cleanup.

## 4. Write pseudocode

Use concrete operations and stopping conditions, not vague phrases.

Weak:

```text
copy the file
```

Useful:

```text
while another read returns bytes
    write all returned bytes
stop successfully when read returns zero
stop unsuccessfully when read or write returns an error
```

Pseudocode should expose the outer and inner loops before C syntax is involved.

## 5. Activate one test suite

Remove `PROJECT_STATUS: TODO` only from the command currently being implemented.

Run its suite immediately:

```sh
make mini_echo
sh tests/test_mini_echo.sh
```

The failures become the behavioral checklist. Keep the other commands skipped.

## 6. Implement the smallest valid path

Start with one successful case. Then add failure handling and edge cases without changing the contract.

A productive order is:

1. argument validation;
2. simplest successful input;
3. repetition;
4. end-of-input;
5. system-call failures;
6. cleanup;
7. exact output formatting.

## 7. Debug with evidence

When a test fails:

1. identify whether the status, standard output, or standard error is wrong;
2. reproduce only that case manually;
3. print or inspect the smallest relevant state;
4. locate the first iteration where reality differs from expectation;
5. fix the cause, not the final symptom;
6. rerun the single suite, then `make check`.

For byte-level mismatches, use:

```sh
od -An -tx1c file
```

For file-copy validation, use:

```sh
cmp source destination
```

## 8. Perform a cold reconstruction

Passing tests proves current correctness, not durable recall.

On a later day:

- open a blank file;
- use only the command README;
- rebuild the state list and pseudocode;
- implement without viewing the previous source;
- compare only after the attempt.

Record the first blocking point. That point—not the whole command—is the next mechanism to drill.

## 9. Commit intentionally

Commit only coherent, working states. Prefer messages that describe behavior:

```text
feat(cat): copy standard input with a fixed buffer
fix(cat): retry incomplete writes
fix(cp): close source when destination open fails
test(wc): cover words split by whitespace transitions
```

Avoid commits such as `update`, `working`, or `final` because they hide the reasoning history that makes the public repository valuable.

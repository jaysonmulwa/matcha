# ADR-0001 — Two orthogonal axes, not one "level" scale

Status: Accepted (v0.2) · Date: 2026-07-14 · Owner: Jayson

## Context

The naive design is a single "reading level" slider: one knob from simple to
advanced. The PRD's founding observation is that this conflates two independent
things — whether a reader can **parse the English** (linguistic) and whether they
**know the domain** (conceptual). Real audiences sit off the diagonal: an L2
engineer (`basic × expert`) knows what a rollback is but wants short sentences; a
fluent executive (`full × novice`) has rich English and no infrastructure schema.

## Decision

Model two orthogonal axes:

- **Linguistic** — persistent preset (`basic`/`plain`/`full`), a property of the
  reader. Informed by CEFR and readability research, with **no conformance claim**.
- **Conceptual** — per-request mode (`novice`/`familiar`/`expert`), a property of
  this artifact's audience. Operationalized as an allowed-operations table.

They compose as a matrix. **Glossing is the only bridge** between them: at lower
linguistic tiers, domain terms that must appear get a one-line inline definition
on first use.

## Consequences

- The worked examples must be matrices, and off-diagonal cells must be shown — they
  are the proof the axes are real (PRD §5.1, §5.3).
- The two axes cannot be operationalized symmetrically: linguistic has instruments
  (frequency lists, FK), conceptual does not — its evaluation is rubric-based
  (layer 2). This asymmetry is accepted as an honest ceiling, not hidden.
- Preset names signal *language*, not intelligence; the neutral fallback is `plain`
  (Invariant #9).

## Alternatives rejected

- **Single level scale** — patronizes the off-diagonal engineer or drowns the
  off-diagonal executive. It is the specific failure this design exists to avoid.
- **CEFR conformance** — implies a governed standard we do not meet and cannot
  test; adopted as loose inspiration only.

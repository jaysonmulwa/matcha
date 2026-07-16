# ADR-0003 — Cut proficiency inference from v1

Status: Accepted (v0.2) · Date: 2026-07-14 · Owner: Jayson

## Context

v0.1 proposed inferring a user's language proficiency from their writing, framed
with IRT (item-response theory) language. This attaches a proficiency judgment to a
person and drives a persistent setting from it.

## Decision

Cut proficiency inference from v1. Settings are **explicit only** (`preset`,
`gloss`, `fk_pin`). The skill may at most **offer once**: "Want me to keep my
English at a set level? basic / plain / full." Correct use of a term suppresses
**that term's gloss locally** — it updates no general estimate.

## Consequences

- v1 is explicit-settings-only; the neutral fallback for an unqualified "simpler"
  request is `plain`, applied as a preset choice, not a proficiency judgment
  (Invariant #9).
- No proficiency judgment is attached to any user (Invariant #9). Gloss suppression
  is strictly local and per-term (Invariant #7).
- Consensual, opt-in assessment returns as a **v2 candidate** only if the platform
  spike shows it can be done without silent profiling.

## Rationale

Writing-based estimation is confounded by short messages, mobile typing,
translation tools, fatigue, disability, and code-switching (a live confound in
multilingual markets). The IRT framing added scientific-sounding precision without
calibrated items — false rigor. Ecosystem tools already own assessment; this skill
should not.

## Alternatives rejected

- **IRT-based silent inference** — false precision, ethically fraught (profiling),
  confounded inputs.
- **Heuristic guess from message length/vocabulary** — same confounds, no
  calibration, still a judgment about a person.

# ADR-0004 — A five-level ladder as the interface, the grid underneath

Status: Accepted · Date: 2026-07-15 · Owner: Jayson
Qualifies: [ADR-0001](./0001-two-orthogonal-axes.md)

## Context

ADR-0001 rejected a single level scale outright: it "patronizes the off-diagonal
engineer or drowns the off-diagonal executive… the specific failure this design exists
to avoid." That still holds. But a week of the two-axis interface exposed a real gap:

- The **linguistic** axis had two controls (`set`, `rewrite`). The **conceptual** axis
  had **none** — reachable only by describing the audience in prose.
- Asked for "something on top of `full`", the honest answer was that nothing sits above
  uncapped English. What was actually wanted was the same English with *less
  hand-holding* — a move along the other axis, which had no handle to grab.
- Measured: the unset default sits around `full × familiar`. A true `full × expert` is
  **terser** than the default, so the top rung is a real capability, not a relabel.

## Decision

Ship a **five-name ladder** as the user-facing control. It is an **L-shaped path**
through the 3×3 grid: raise English to the ceiling, then drop the hand-holding.

| Level | Grid cell | What moves |
|---|---|---|
| `basic` | basic × novice | English |
| `plain` | plain × novice | English |
| `full` | full × novice | English maxes out here |
| `familiar` | full × familiar | domain |
| `expert` | full × expert | domain |

**The grid stays underneath.** The ladder is ergonomics, not the model. The five names
map to `(row, column)` pairs; the knobs remain independent; off-ladder cells are
reachable by asking ("short sentences but assume I know Kubernetes").

`set` and `rewrite` both take any of the five, so the conceptual axis finally gets the
controls the linguistic one always had.

## Consequences

- **Every level now writes a CLAUDE.md block.** Previously `set full` wrote none,
  because `full` was a bare linguistic ceiling with nothing to enforce. As a ladder
  rung, `full` means `full × novice` — explain mechanisms, gloss terms — which is a
  real instruction and differs from the default. The old "full is a no-op" note is
  obsolete.
- **The config key is `level:`, not `preset:`.** `familiar` and `expert` are not
  linguistic presets; the old name was a lie.
- **Conceptual mode becomes persistent, which ADR-0001's logic argues against.**
  Knowledge is per-domain: `set expert` gives terse answers about molecular biology
  too. Accepted deliberately — the escape is one rung down for one response
  (`rewrite familiar`). Pull, not push. If this proves annoying in use, per-project
  defaults (PRD v2) are the follow-up, better designed for having felt the friction.
- **The cost is four cells:** `basic × expert`, `basic × familiar`, `plain × expert`,
  `plain × familiar` — every case where English is low but domain knowledge is high.
  That includes the L2 engineer, ADR-0001's founding case. They stay reachable by
  request but have no rung. Acceptable because a single fluent reader never needs them
  for their own reading; they matter only when writing *for* such a colleague.

## Alternatives rejected

- **Replace the grid with a 1–5 scale** (the literal reading of the request) — saves a
  few lines and permanently kills `basic × expert`. The ladder-over-grid costs one
  mapping table and loses nothing.
- **A sixth level above `expert`** — there is nothing above uncapped English plus no
  hand-holding. The request for "on top of `full`" was a move along the *other* axis,
  not a further rung on the same one.
- **A separate `/matcha explain` command** — a second verb for what `rewrite <level>`
  already does. The value spaces are disjoint, so one verb can carry both axes.

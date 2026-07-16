# ADR-0002 — Fidelity-first: every rendering starts from an explicit fact set

Status: Accepted (v0.2) · Date: 2026-07-14 · Owner: Jayson

## Context

v0.1 promised "the same information at every tier." That is both untestable and
false — tiers legitimately change what is shown. Worse, without a defined source of
truth, an omission is indistinguishable from a loss: you cannot tell calibration
from damage. The v0.1 worked examples themselves introduced unsupported detail
(jitter, singleflight, a p99 number, a "cache-aside" pattern name the source never
stated).

## Decision

1. Add **Invariant #0**: never introduce an unsupported factual claim. Calibration
   may omit, reorganize, explain, or qualify source claims — only that.
2. Every rendering begins from an explicit or reconstructable **source fact set**
   (F1..Fn).
3. A four-stage, non-commutative pipeline:
   `source facts → purpose selection → conceptual framing → linguistic realization`.
4. Split the contract into three separately-tested properties: **Correctness** (no
   unsupported claim), **Completeness** (required facts survive), **Relevance**
   (non-required facts may be omitted; rendering matches tiers).
5. Build the **fidelity harness before the renderer** (phase v0.5): fact checklists
   plus a forbidden-additions check, seeded with the §5 examples.

Slogan: **tiers change rendering; purpose changes selection; nothing changes
truth.**

## Consequences

- "Completeness" is purpose-relative: a fact is *hideable* iff it is not in
  `required_facts` for the declared purpose. This is what distinguishes a novice
  explanation from an incomplete one.
- Uncertainty markers and numbers are required facts — they survive even at
  `basic × novice` ("should get faster", "22.31%").
- The build order inverts intuition: the guardrail is written before the thing it
  guards, so v1 renders against a harness that can already fail it.
- Layer-3 eval is the load-bearing test; forbidden-addition detection is the gate
  for phase v0.5.

## Alternatives rejected

- **"Same information at every tier"** — untestable and self-contradictory.
- **Phrase first, fact-check after** — by the time text exists, omission and loss
  are indistinguishable. Selection must precede phrasing.

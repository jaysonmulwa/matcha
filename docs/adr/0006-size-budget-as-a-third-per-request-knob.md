# ADR-0006 — Size budget as a third per-request knob

Status: Accepted · Date: 2026-10-22 · Owner: Jayson
Relates: ADR-0001 (two axes), ADR-0004 (ladder), PRD v0.2 §"No lower bounds"

## Context

A common request shape is *"using matcha plain, in 4-6 sentences, explain this issue
and solution"*. The skill had rules for the level and the audience but nothing for
the size. Claude handled the number by instinct, so results were inconsistent: some
answers padded to hit the count, some dropped a required fact to fit, and none said
which had happened.

The two-knob model (ADR-0001) is about *how* a reader parses and *what* they already
know. Size is neither. Forcing it into a level would multiply the ladder by every
plausible count.

## Decision

Treat the budget as a **third knob, per request only**.

- Parsed from natural language: "in N sentences", "in N-M sentences", "in N to M
  sentences", the same with "lines". A bare range defaults to sentences.
- A sentence ends at `.`, `!` or `?` outside code and quotes. A line is one rendered
  line of prose. Code, quoted material and glosses are not counted — rule 3 already
  says they are carried whole.
- A range passes at any count inside it. A fixed number means exactly that count. The
  budget caps length only; it never relaxes the level's word-per-sentence cap.
- Collisions route through rule 4. If the budget cannot hold the required facts, the
  skill says what will not fit and gives the closest faithful version inside the
  budget. Padding and silent drops are both failures.
- It never persists. `set` does not accept a budget and `~/.claude/matcha.md` never
  stores one. This mirrors rule 5 ("simplify" is per-request).

The rule text lives once in `skills/matcha/SKILL.md` and is mirrored into `AGENTS.md`
and the vendor rules files. The per-level activation files under
`skills/matcha/levels/` are unchanged, because the budget is not ambient.

## Consequences

- A request with a budget now has a defined pass condition that a reader can check
  by counting. Before, "4-6 sentences" was advice.
- Padding is named as a failure. Hitting a count by adding filler is as wrong as
  dropping a fact, because both change what the text says relative to the source.
- Counting by punctuation is a heuristic. Abbreviations like "e.g." and decimals
  inside quotes can miscount. The rule tolerates this because the count is a
  budget, not a metric the skill is scored on.
- Lines are weaker than sentences. Rendering width varies by tool, so "3 lines" is
  only reliable where the output is plain prose with no wrapping ambiguity. The rule
  accepts lines because users ask for them, and states what a line is.

## Alternatives rejected

- **Make size part of the level** (e.g. `plain-short`) — explodes the ladder and
  conflates length with English level, which ADR-0001 keeps apart.
- **Persist the budget via `set`** — a saved count would cap every answer in every
  session, including ones where the question needs more. Size belongs to the
  question, not the reader.
- **Count words instead of sentences** — users ask in sentences and lines. A word
  budget would need a translation step the user never asked for.

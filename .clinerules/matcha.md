<!-- Mirror of AGENTS.md. Keep the body identical. -->
# matcha — write for the reader in front of you

Adapt the level of English and the domain knowledge you assume. Never adapt the facts.

Trigger when the user asks to simplify or reword, names an audience ("for my exec",
"for an L2 engineer", "for the customer"), or asks for a level by name.

## Two knobs, kept separate

- **linguistic** — can the reader parse the English?
- **conceptual** — do they know the domain?

An L2 engineer wants short sentences *and* no hand-holding. A fluent executive wants
rich English *and* the mechanism explained. Never collapse the two into a single scale.

## The five levels

| Level | English | Domain framing |
|---|---|---|
| `basic` | ≤14 words/sentence; ~1000 common words; gloss every domain term | mechanisms explained; analogies flagged |
| `plain` | ≤20 words/sentence; everyday vocabulary; gloss obscure terms | mechanisms explained; analogies flagged |
| `full` | uncapped | mechanisms explained; terms glossed |
| `familiar` | uncapped | mechanism in one clause; no gloss |
| `expert` | uncapped | terms used directly; internals shown; terse; no unsolicited analogies |

Maxima only — a clear 8-word sentence never fails `basic`. Proper nouns, product names
and code identifiers don't count against vocabulary. Off-ladder combinations are real:
"short sentences, but assume I know Kubernetes" is `basic` English with `expert`
framing — honour it over the ladder. If no level is named and the user asks for
something simpler, use `plain`.

## Rules

1. **Add nothing the source doesn't say.** Omit, reorganize, explain, or qualify —
   never introduce. Keep uncertainty markers: if a change is *intended* to be faster,
   write "should get faster".
2. **Keep qualifiers welded to their numbers.** "Variable rate, currently 22.31%" is
   one fact — "your rate is 22.31%" is grounded and still a lie.
3. **Never calibrate** code, commands, error messages, or quoted material.
4. **Report collisions.** If the level would cost required detail, say what can't be
   simplified and give the closest faithful version — don't drop it silently.
5. **"Simplify" is per-request.**
6. **Gloss once per conversation.** Never re-gloss; never gloss a term the user used.
7. **Simple English is not childish English.** GOV.UK register. Judge no one's
   proficiency.

## Size budget

A request may carry a size budget alongside the level: "in 4-6 sentences", "in 5
sentences", "in 3 lines", "4 to 6 sentences". A bare "4-6" means sentences. The budget
is a third per-request knob, not a level, and never persists.

- **Counting.** A sentence ends at `.`, `!` or `?` outside code and quotes. A line is one
  rendered line of prose. Code, quoted material and glosses are carried whole (rule 3)
  and are not counted.
- **Range → any count inside it passes. Fixed number → exactly that count.** The level's
  word-per-sentence cap still applies inside the budget.
- **Collision → rule 4.** If the budget cannot hold the required facts, say what will
  not fit and give the closest faithful version inside the budget. Never pad to reach
  a count; never drop a required fact silently.

**Scope:** the *persistent* level (Claude Code's `/matcha set`) doesn't port here — it
relies on Claude Code hooks. In this tool, name the level per request.

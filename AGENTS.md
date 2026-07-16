# matcha — write for the reader in front of you

Adapt the level of English, the domain knowledge assumed, and the amount of jargon.
Never adapt the facts.

Apply when the user asks to simplify, reword, or "dumb it down"; when they name an
audience ("for my exec", "for an L2 engineer", "for the customer"); or when they ask
for a level by name.

## The grid

Two knobs, independent of each other:

- **linguistic** — can the reader parse the English?
- **conceptual** — do they know the domain?

They do not collapse into one scale. An L2 engineer wants short sentences *and* no
hand-holding. A fluent executive wants rich English *and* the mechanism explained.
One combined "level" patronizes the first and drowns the second.

## The five levels

An L-shaped path through the grid — the first three raise the English, the last two
drop the hand-holding.

| Level | English | Domain framing |
|---|---|---|
| `basic` | max 14 words/sentence; ~1,000 common words; gloss every domain term on first use | explain mechanisms plainly; analogies allowed, **flagged as analogy** |
| `plain` | max 20 words/sentence; everyday vocabulary; gloss obscure terms only | explain mechanisms plainly; analogies allowed, flagged |
| `full` | uncapped | explain mechanisms plainly; gloss terms on first use |
| `familiar` | uncapped | mechanism in one clause; brief context for terms |
| `expert` | uncapped | use domain terms directly; show internals; be terse; **never an unsolicited analogy** |

Maxima only — a clear 8-word sentence never fails `basic`. Proper nouns, product names
and code identifiers don't count against vocabulary. Off-ladder combinations are real:
"short sentences, but assume I know Kubernetes" is `basic` English with `expert`
framing. Honour that over the ladder.

If no level is stated and the user asks for something simpler, use `plain`.

## Rules

1. **Add nothing the source doesn't say.** You may omit, reorganize, explain, or
   qualify — never introduce. If the source says a change is *intended* to be faster,
   write "should get faster" at every level. Uncertainty markers are content, not
   decoration.
2. **Keep qualifiers welded to their numbers.** "Variable rate, currently 22.31%" is
   one fact — "your rate is 22.31%" is grounded and still a lie.
3. **Never calibrate** code, commands, error messages, or quoted material. Content
   that loses its meaning when decomposed (a legal clause, an ordered procedure) is
   carried whole.
4. **Report collisions.** If the level would cost required detail, don't drop it
   silently and don't gloss every other sentence. Say what can't be simplified, give
   the closest faithful version, offer the original alongside.
5. **Adaptation is per-request.** "Simplify" changes this response only.
6. **Gloss once per conversation.** Never re-gloss; never gloss a term the user
   themselves used; draw no wider conclusion from either.
7. **Simple English is not childish English.** GOV.UK register: complex content in
   plain words, no cheeriness inflation. Judge no one's proficiency — levels are
   writing choices.

---

**Note on scope.** This file carries matcha's request-driven half, which is portable.
The persistent level (`/matcha set plain`, applied automatically to every later
session) relies on Claude Code's CLAUDE.md activation and config injection, and has no
equivalent here yet. In this tool, ask for a level per request.

# `matcha`

```
         ) )
        ( (
     .---------.
     |         |\
     |         | |
     |         | |
     |         |/
      \_______/
```

*For when you don't follow what Claude just told you about your own PR.*

Five levels, from plain English for your exec up to no-hand-holding for your own
codebase. You set the level; matcha writes to it and doesn't make things up.

**Status: v1** (2026-07-15). Claude Code skill. Source:
[skill/matcha/SKILL.md](./skill/matcha/SKILL.md).

## Install

Requires Claude Code (tested on 2.1.210). One skill directory, nothing else.

```bash
# personal — available in all your projects
mkdir -p ~/.claude/skills/matcha
cp skill/matcha/SKILL.md ~/.claude/skills/matcha/

# or per-project — commit it with the repo
mkdir -p .claude/skills/matcha
cp skill/matcha/SKILL.md .claude/skills/matcha/
```

Then, inside Claude Code:

```
/matcha set plain          # any of the five levels — persists across sessions
/matcha rewrite familiar   # one-shot, config untouched
/matcha status             # check what's configured
/matcha set off            # remove everything it wrote
```

The skill is **inert until you `set` a level**. `set` asks approval to write two
files: `~/.claude/matcha.md` (your level) and a marker-delimited block in
`~/.claude/CLAUDE.md` (the ambient activation — see [design.md §6](./design.md) for
why the rules must ride there). It never touches CLAUDE.md content outside its
markers, and `set off` removes both cleanly.

No level needed for one-shots: `/matcha rewrite basic` re-renders the previous
response, or just ask — "simplify this", "rewrite for my exec".

## The five levels

Two independent knobs — **linguistic** (can the reader parse the English?) and
**conceptual** (do they know the domain?). The ladder is an **L-shaped path** through
them: levels 1–3 raise the English, 4–5 drop the hand-holding.

| Level | English | Domain framing | Grid cell |
|---|---|---|---|
| `basic` | ≤14 words/sentence, ~1,000 common words, gloss everything | mechanisms explained; analogies flagged | basic × novice |
| `plain` | ≤20 words/sentence, everyday vocabulary, gloss obscure terms | mechanisms explained; analogies flagged | plain × novice |
| `full` | uncapped | mechanisms explained; terms glossed | full × novice |
| `familiar` | uncapped | mechanism in one clause; brief context for terms | full × familiar |
| `expert` | uncapped | terms used directly; internals shown; terse; **no unsolicited analogies** | full × expert |

**The ladder is a path, not the whole grid** ([ADR-0004](./adr/0004-five-level-ladder-over-the-grid.md)).
The knobs stay independent underneath:

```
                    ← conceptual: does the reader know the domain? →
                 novice          familiar         expert
              ┌───────────────┬───────────────┬───────────────┐
   basic      │  ① basic      │      ·        │      ·        │  ↑
              │               │               │  L2 engineer  │  │
              ├───────────────┼───────────────┼───────────────┤  linguistic:
   plain      │  ② plain      │      ·        │      ·        │  can they parse
              │               │               │               │  the English?
              ├───────────────┼───────────────┼───────────────┤  │
   full       │  ③ full ──────┼─→ ④ familiar ─┼─→ ⑤ expert    │  ↓
              │  the exec     │  ← default    │  no teaching  │
              └───────────────┴───────────────┴───────────────┘
                 ①②③ raise the English · ③④⑤ drop the hand-holding
                 ·  = real cell, no rung — ask for it in words
```

The four `·` cells are **low English × high domain knowledge**. The clearest is
`basic × expert`: an L2 engineer who knows exactly what a rollback is and just wants
short sentences. That case is ADR-0001's founding example, and the ladder can't reach
it — but the grid underneath still can: *"short sentences, but assume I know
Kubernetes."* A request like that wins over the ladder.

### The grid on one PR

Source facts: a Redis cache was added to `/auth/token`, TTL 5 minutes, DB fallback on
miss, invalidated on password change, *intended* to cut DB load and latency (not
measured). Every cell may omit, reorder, or explain these — none may add to them.

| | **novice** | **familiar** | **expert** |
|---|---|---|---|
| **basic** | "Logins should get faster. The app now saves recent login checks for a short time, so it does not repeat slow work. If you change your password, the saved check is cleared." | "We added a cache (a fast, short-term memory store) for login checks. Repeat logins can skip the database for up to 5 minutes. A password change clears the cached entry." | "Added Redis cache on `/auth/token`. TTL 5 min. DB path kept as fallback on miss. Invalidation on password change. Goal: lower DB load and login latency." |
| **plain** | "Login speed should improve. The system now keeps recent login results on hand for a few minutes instead of recomputing them each time. Changing your password clears the stored result, so old credentials can't be reused." | "Auth responses are now cached in Redis for 5 minutes, so repeated logins skip the database lookup. Cache entries are invalidated on password change, and the database path remains as fallback." | "Redis cache added on `/auth/token`, 5-min TTL, DB fallback on miss, invalidation on password change. Motivation: DB load and p-latency reduction — intended, not yet measured." |
| **full** | "Login latency should drop: the endpoint now retains recent verification results for five minutes rather than recomputing them on every request. A password change immediately clears the retained result, so revoked credentials cannot ride on a stale entry." | "The auth endpoint now employs a Redis-backed cache (5-minute TTL) that eliminates redundant database round-trips for repeat authentications; entries are invalidated on password change and the database path is preserved as fallback." | "Introduced a Redis cache on `/auth/token`: 5-min TTL, database fallback on miss, invalidation on credential change. Expected effect is reduced DB load and login latency; no benchmark accompanies the PR." |

Read it **down a column** and the English changes while the facts hold. Read it
**across a row** and the facts on the page change while the English holds. That
separation is the entire thesis.

Two details worth catching: *"should"* survives even at `basic × novice`, because the
speedup is an **intention**, not a measurement — uncertainty is a fact, not decoration.
And no cell names the pattern "cache-aside", because **the PR never did**. Naming it
would be a claim about the design that nobody made.

**Where your default sits:** around `familiar`. Measured — an unset session answered a
Redis question in 22-word sentences with unglossed jargon, but still explained
mechanisms. So `expert` is genuinely *above* the default (terser, no teaching), and
`full` is genuinely *below* it (same English, more explanation). Every level does
something.

**Windows note:** the skill reads its config via an inline `` !`cat …` `` command,
which runs under Git Bash — present with any standard Git for Windows install.

| Doc | What |
|---|---|
| [design.md](./design.md) | How it's built, what it can't do, build/test findings. |
| [level-match-prd-v0.2.md](./level-match-prd-v0.2.md) | The PRD — full intent, tier tables, worked examples. Kept verbatim under the **working name `level-match`**; it called for a final name before publishing, and `matcha` is it. |
| `could-have-been.md` | The fidelity architecture we drafted and cut, and why. **Gitignored — local only**, not in a clone. |

## What the English knob actually changes

Measured by diffing two renders of the same CRISPR explanation, `plain` → `full` —
i.e. the *linguistic* move (levels 2 → 3). Only three of these five are specified in
the skill; the other two the model supplies from general register sense, which means
they work but are **unguaranteed and unlintable**.

| Dimension | `plain` → `full` | Observed | Specified? |
|---|---|---|---|
| **Vocabulary register** | ~2,000–3,500 words → uncapped; in practice Germanic → Latinate | "a chosen **spot**" → "a chosen **location**"; "It **came from** bacteria" → "it **originates in** a bacterial defence system"; "not every spot **can be cut**" → "not every site **is addressable**" | yes — table |
| **Sentence length** | max 20 words → unrestricted | plain: *"The cut alone changes nothing."* (5 words), none over 20. full: a 33-word sentence with a semicolon | yes — table |
| **Glossing** | obscure terms only → none | plain: *"a short piece of RNA, a molecule closely related to DNA"*. full: no glosses | yes — table |
| **Grammar ceiling / nesting** | moderate → unrestricted | plain: flat declaratives. full: semicolons, *"**whereupon** Cas9 cuts"*, participial openers (*"Left to its own devices…"*) | **no** |
| **Paragraph & structure density** | shorter paragraphs, more scaffolding → dense prose | plain: 5 bolded section headers. full: headers gone, five long paragraphs | partial — the register rule says "shorter paragraphs at lower presets"; nothing about headers |

A sixth, **idioms**, behaves the same way: full used *"Left to its own devices"* where
plain said *"Left to itself"*. The PRD's tier table has an idioms column; the shipped
skill doesn't.

**Why that's fine.** Grammar ceiling and idioms were dropped in the cut, and both fired
correctly anyway across four renders — evidence they were doing no work. They're
free-riding on model judgment, which is exactly the category
[design.md §4](./design.md) says to state honestly rather than engineer around. If an
idiom ever shows up at `basic` in real use, add one line.

The *conceptual* move (levels 3 → 4 → 5) changes something different: not how it's
said, but **what's on the page**. Holding English at `plain` across all three columns,
`expert` carried PAM, NHEJ, S/G2 and exa-cel — none of which appear at `novice` — and
the molecular-scissors analogy present at `novice` correctly vanished. Rows change
rendering; columns change selection.

## Related literature

Loose inspirations, not conformance claims — each taken narrower than the source.
Full notes in the [PRD appendix](./level-match-prd-v0.2.md#appendix--literature-condensed-loose-inspirations-not-conformance).

| Source | What we took |
|---|---|
| **CEFR** (Council of Europe language framework) | The band structure and the scale L2 readers already know themselves by. Presets are "CEFR-informed", never CEFR-conformant. |
| **Nation's frequency research / NGSL / Oxford 3000** | Word-frequency lists as the vocabulary mechanism — inverted: they target *acquisition* (stretch the learner); we target *comprehension* (stay inside the reader's range). |
| **Flesch-Kincaid** | A two-variable readability proxy, used as an instrument and disagreement-detector only — never as ground truth. Optional `fk_pin` exists solely for compliance rules written as grade levels. |
| **Coh-Metrix line of research** | The key negative result: deleting connectives ("because", "so") *improves* FK while *lowering* comprehension. This is why FK-driven revision must shorten sentences, never strip connectives. |
| **Dreyfus skill-acquisition model** | The ladder shape and one insight: expertise changes *which objects exist* for the reader (a novice sees steps; an expert sees "a rollback"). Adapted from performance to comprehension; cited as lineage, not authority. |
| **Sweller / Kalyuga — Cognitive Load Theory, expertise-reversal effect** | The empirical basis for mode-dependent rendering: unsolicited scaffolding measurably harms readers who already hold the schema. Hence "no unsolicited teaching analogies at expert". |
| **GOV.UK style guide / ISO 24495-1 (plain language)** | The register model and existence proof: complex content in plain language that never infantilizes. "Simple English is not childish English" is their lesson. |

## ADRs

| # | Decision |
|---|---|
| [0001](./adr/0001-two-orthogonal-axes.md) | Two orthogonal axes (linguistic × conceptual), not one level scale. |
| [0002](./adr/0002-fidelity-first-fact-set-pipeline.md) | Fidelity first: add nothing the source doesn't say. |
| [0003](./adr/0003-cut-proficiency-inference.md) | No proficiency inference — explicit settings only. |
| [0004](./adr/0004-five-level-ladder-over-the-grid.md) | Five-level ladder as the interface, grid underneath. Qualifies 0001. |

**v0 spike: done** — ambient activation works via CLAUDE.md include; a bare skill
description does **not** self-activate ([design.md §6](./design.md)).
**v1: built and tested.** [skill/matcha/SKILL.md](./skill/matcha/SKILL.md)
is the canonical source; an installed copy under `~/.claude/skills/` is a deployment
of it — edit the canonical one and re-copy. Next: use it for a week; run
skill-creator evals if triggering or adherence feels off.

---
name: matcha
description: Adapt English level and explanation depth to the reader. Use when the user asks to simplify, reword, "dumb it down", make text accessible, or write for a stated audience ("for my exec", "for an L2 engineer", "for the customer") — or when a configured level must be applied.
when_to_use: Trigger phrases - simplify this, plainer English, easier words, explain for a non-engineer, rewrite for X, no hand-holding, assume I know this. Also /matcha set|rewrite|status commands.
argument-hint: "[set|rewrite|status] [basic|plain|full|familiar|expert|off]"
arguments: [action, level]
allowed-tools: Read, Write, Edit
---

## Configured level

!`cat ~/.claude/matcha.md 2>/dev/null || echo "level: none"`

## The ladder

Five levels over two independent knobs — **linguistic** (can the reader parse the English?) and **conceptual** (do they know the domain?). Levels 1–3 raise the English; 4–5 drop the hand-holding.

| Level | English | Domain framing |
|---|---|---|
| **basic** | max 14 words/sentence; ~1,000 common words; gloss every domain term on first use | explain mechanisms plainly; analogies allowed, **flagged as analogy** |
| **plain** | max 20 words/sentence; everyday vocabulary; gloss obscure terms only | explain mechanisms plainly; analogies allowed, flagged |
| **full** | uncapped | explain mechanisms plainly; gloss terms on first use; analogies allowed, flagged |
| **familiar** | uncapped | mechanism in one clause; brief context for terms; analogies **on request only** |
| **expert** | uncapped | use domain terms directly; show internals, parameters, edge cases; be terse; **never an unsolicited analogy** |

Maxima only — a clear 8-word sentence never fails `basic`. Proper nouns, product names and code identifiers don't count against vocabulary. `gloss: off` in config → never gloss, keep every other rule.

**The ladder is a path, not the whole grid.** The two knobs stay independent, and the four off-ladder cells are real: low English × high domain knowledge. "Short sentences but assume I know Kubernetes" is `basic` English × `expert` framing — an L2 engineer. Honour a request like that over the ladder.

## Dispatch — action: "$action", arg: "$level"

- **empty** → ambient: apply the configured level. If `none` and the user asked to simplify, use `plain` for this response only.
- **`set <level>`** → write `~/.claude/matcha.md` with two lines: `level: $level` and `gloss: auto` (keep an existing `gloss:` value if the file has one). Then upsert into `~/.claude/CLAUDE.md`, between `<!-- matcha:start -->` and `<!-- matcha:end -->`, a block naming the level and spelling out **both** of its rules from the table above — enough to act on without the skill loaded, because an "invoke the skill" pointer alone does not reliably activate. Replace the block if the markers exist; append if not; create the file if missing. **Never touch anything outside the markers.** Confirm in one line.
- **`set off`** → delete `~/.claude/matcha.md` and remove the marker block. Delete CLAUDE.md only if the block was its entire content.
- **`rewrite <level>`** → re-render your previous response (or text the user supplied) at that level, one-shot. **Never change the config.**
  - No level given → use the configured level; if none, `plain`.
  - Previous response already at that level → say so and stop; don't re-emit near-identical text.
  - Rewriting *up* cannot recover what the source dropped. Render the same facts richer — never add new ones. If they want the fuller version, they should re-ask the question, which re-sources from your knowledge.
- **`status`** → the configured level, both its rules, and which terms you have glossed this conversation.

## Rules

1. **Add nothing the source doesn't say.** You may omit, reorganize, explain, or qualify — never introduce. If the source says a change is *intended* to be faster, write "should get faster" at every level. Uncertainty markers are content, not decoration.
2. **Keep qualifiers welded to their numbers.** "Variable rate, currently 22.31%" is one fact — "your rate is 22.31%" is grounded and still a lie.
3. **Never calibrate** code, commands, error messages, or quoted material. Content that loses its meaning when decomposed (a legal clause, an ordered procedure) is carried whole.
4. **Report collisions.** If the level would cost required detail, don't drop it silently and don't gloss every other sentence. Say what can't be simplified, give the closest faithful version, offer the original alongside with plain notes.
5. **"Simplify" is per-request.** It never changes the saved level. If ambiguous, state your reading in half a sentence: "keeping the numbers, dropping the mechanism — say 'simpler English' if you meant the wording."
6. **Gloss once per conversation.** Never re-gloss; never gloss a term the user themselves used; draw no wider conclusion from either.
7. **Simple English is not childish English.** GOV.UK register: complex content in plain words, no cheeriness inflation, shorter paragraphs at lower levels. Judge no one's proficiency — levels are writing choices; the neutral fallback is `plain`.

If asked what this skill guarantees: it adds nothing the source doesn't support, keeps facts the user declares required, and reports when a level can't hold required detail. It does not promise to have spotted every fact worth keeping — completeness beyond declared facts is best-effort.

# Design — `matcha`

Companion to [prd-v0.2.md](./prd-v0.2.md). The PRD says *what* and *why*; this says
*how it's built* and *what it can't do*.

**The project in one sentence:** a skill that rewrites what Claude says to match the
reader's English level and domain knowledge, without making things up.

## 1. The idea

Two knobs, independent — that's the whole design ([ADR-0001](./adr/0001-two-orthogonal-axes.md)):

- **Linguistic** — can the reader parse the English? `basic` / `plain` / `full`.
- **Conceptual** — does the reader know the domain? `novice` / `familiar` / `expert`.

Off-diagonal audiences are the point: the L2 engineer (`basic × expert`) knows what a
rollback is and wants short sentences; the fluent executive (`full × novice`) has rich
English and no infrastructure schema. One combined "level" slider patronizes the first
and drowns the second. **Glossing is the bridge** — at low linguistic tiers, domain
terms that must appear get a one-line inline definition on first use.

**The interface is a five-rung ladder over that grid**
([ADR-0004](./adr/0004-five-level-ladder-over-the-grid.md)): `basic` → `plain` →
`full` → `familiar` → `expert`, an L-shaped path that raises English to the ceiling
then drops the hand-holding. The grid stays underneath — the ladder is ergonomics, not
the model, and off-ladder cells are reachable by asking. This is the one place the
build knowingly qualified ADR-0001: the conceptual axis had no controls at all, and a
ladder was the cheapest way to give it some.

Tier tables, the operations table, and the worked examples live in the PRD (§4, §5).
They stand as written.

## 2. What got built (v1, shipped 2026-07-15)

**One skill: `skills/matcha/SKILL.md`**, shipped as a plugin (`.claude-plugin/plugin.json`)
with a single-plugin marketplace (`.claude-plugin/marketplace.json`, `source: "./"`) so
`/plugin marketplace add jaysonmulwa/matcha` + `/plugin install matcha@matcha` works;
manual copy into `~/.claude/skills/matcha/` remains supported. Commands: `/matcha set
<level|off>`, `rewrite <level>`, `status`, plus ambient triggering on
simplify/audience phrasing. Both verbs take any of the five ladder rungs, so the
conceptual axis has the controls the linguistic one always had. Config lives in
`~/.claude/matcha.md` (`level:`, `gloss:`), injected at load time via `` !`cat …` ``
dynamic context. `set` writes the config **and** upserts a marker-delimited block in
`~/.claude/CLAUDE.md`; `set off` removes both. **Every rung writes a block** — as a
ladder rung `full` means `full × novice` (explain mechanisms, gloss terms), which is a
real instruction and differs from the default. It is no longer a no-op.

Two findings from build-time testing (fresh headless sessions, haiku):

- **Indirection kills activation.** A CLAUDE.md block saying only "invoke the
  matcha skill" did *not* activate a fresh session. The same block with the
  preset's core rules inline (3 lines: sentence cap, vocabulary, glossing) activated
  cleanly — every sentence ≤14 words on the first try. So the block carries the rules;
  the skill invocation line is enrichment. Docs purity ("CLAUDE.md = facts, skills =
  procedures") lost to measured behavior.
- **`~/.claude` config writes can't be pre-approved headless.** Neither frontmatter
  `allowed-tools` nor `--allowedTools` unblocks writes to `~/.claude/CLAUDE.md` in
  `-p` mode. Fine for the product — `set` is interactive; the user approves two writes
  once.

`lint` remains unbuilt — optional stdlib script if ambient adherence proves weak;
advisory only, it can count sentences and cannot check meaning.

### 2.1 What the levels measurably change

From diffing renders of the same CRISPR explanation.

**The English move** (`plain` → `full`, rungs 2 → 3). Only three of these five are
specified in the skill; the other two the model supplies from general register sense,
so they work but are **unguaranteed and unlintable**.

| Dimension | `plain` → `full` | Observed | Specified? |
|---|---|---|---|
| **Vocabulary register** | ~2,000–3,500 words → uncapped; in practice Germanic → Latinate | "a chosen **spot**" → "a chosen **location**"; "It **came from** bacteria" → "it **originates in** a bacterial defence system"; "not every spot **can be cut**" → "not every site **is addressable**" | yes — table |
| **Sentence length** | max 20 words → unrestricted | plain: *"The cut alone changes nothing."* (5 words), none over 20. full: a 33-word sentence with a semicolon | yes — table |
| **Glossing** | obscure terms only → none | plain: *"a short piece of RNA, a molecule closely related to DNA"*. full: no glosses | yes — table |
| **Grammar ceiling / nesting** | moderate → unrestricted | plain: flat declaratives. full: semicolons, *"**whereupon** Cas9 cuts"*, participial openers (*"Left to its own devices…"*) | **no** |
| **Paragraph & structure density** | shorter paragraphs, more scaffolding → dense prose | plain: 5 bolded section headers. full: headers gone, five long paragraphs | partial — the register rule says "shorter paragraphs at lower levels"; nothing about headers |

A sixth, **idioms**, behaves the same way: full used *"Left to its own devices"* where
plain said *"Left to itself"*. The PRD's tier table has an idioms column; the shipped
skill doesn't.

**Why that's fine.** Grammar ceiling and idioms were dropped in the cut, and both fired
correctly anyway across four renders — evidence they were doing no work. They're
free-riding on model judgment, which is exactly the category §4 says to state honestly
rather than engineer around. If an idiom ever shows up at `basic` in real use, add one
line.

**The conceptual move** (rungs 3 → 4 → 5) changes something different: not how it's
said, but **what's on the page**. Holding English at `plain` across all three columns,
`expert` carried PAM, NHEJ, S/G2 and exa-cel — none of which appear at `novice` — and
the molecular-scissors analogy present at `novice` correctly vanished. Rows change
rendering; columns change selection.

## 3. Rules that carry their weight

Everything the fidelity work yielded, compressed (`could-have-been.md` has the
reasoning — gitignored, local only):

- **Add nothing the source doesn't say.** Calibration may omit, reorganize, explain, or
  qualify — only that ([ADR-0002](./adr/0002-fidelity-first-fact-set-pipeline.md)).
- **Keep qualifiers welded to their numbers.** "variable rate, currently 22.31%" is one
  fact. Split it and "your rate is 22.31%" is grounded *and* a lie. This is the single
  most useful mechanical rule.
- **Report collisions.** If the requested level would cost required detail, say so and
  show the closest faithful version — a first-class output, not a failure (PRD §5.5).
- **Only promise what was declared.** Say "keeps the facts you declare required," never
  "preserves all task-critical facts."
- **No proficiency judgment about anyone.** Explicit settings only; neutral fallback is
  `plain` ([ADR-0003](./adr/0003-cut-proficiency-inference.md)).

## 4. Known limits (state them; don't engineer around them)

A pressure-test of the fidelity claims found one wall, six times over: **model judgment
is not independent of itself.** The consequences are permanent, not bugs:

- **Correctness is checkable; completeness isn't.** Additions are visible — a fabricated
  claim is a string you can trace. Omissions are invisible — you can't enumerate what
  should have been said without redoing the same fallible reading. So completeness is
  only ever guaranteed against a set the **user declared**.
- **Self-checking is weakest where it matters.** A second pass shares the first's
  priors, so it catches implausible errors (rare) and waves through plausible ones (the
  dangerous kind). Voting more passes reduces variance, not bias.
- **Verification decays toward `basic × novice`.** The more the text is reworded, the
  less any check is a lookup and the more it's a judgment call. The hardest cells to
  render faithfully are the hardest to verify faithfully.
- **Misleading juxtapositions won't all be caught.** Showing "the instalment looks the
  same" without "the term resets" misleads, and spotting that requires domain judgment
  the skill may not have.

**The response to all four is honesty, not architecture.** Say what isn't promised
(SKILL.md does), report collisions, and let the user declare what must survive. The
apparatus that would *try* to close these — fact graphs, two-hop grounding,
required-closure, tier-stratified eval — is drafted in `could-have-been.md`
(gitignored, local only) and deliberately unbuilt.

## 5. Build order

| Phase | Do | Gate |
|---|---|---|
| **v0 — spike** | Prove the platform can host this: does a saved preset actually make the skill activate in *later* conversations? Can it see its own last response (`rewrite`/`lint` need that)? What survives prompt-only? | activation works across ≥2 sessions |
| **v1** | Write the SKILL.md. Ship. | it reads well and doesn't lie |
| **later, if asked** | `fk_pin`, lint script, declared-facts path | a user asks |

**v0 first** because the whole premise is a persistent preset that quietly applies
later — an inert-until-configured skill still has to load to discover its config. If
that doesn't work, this degrades to an explicit-invocation tool and the design changes.
No interface commitments until that's known.

**v1 is Correctness-only**: adds nothing unsupported, best-effort completeness, reports
collisions. No completeness guarantee, because guaranteeing it needs a declaration
surface nobody has asked for.

`purpose` (understand / decide / act / review) stays an **internal frame** in v1 — it's
what decides which facts matter, but it needs no UI to do that job.

## 6. Spike results (run 2026-07-15, Claude Code 2.1.210 / Windows)

Method: installed a marker-emitting test skill + config, spawned fresh headless
`claude -p` sessions with an ordinary question ("explain what a Redis cache does" —
nothing that topically triggers a language skill), checked for the marker.

| Mechanism | Result | Evidence |
|---|---|---|
| Skill trigger description alone | **FAIL** | Skill registered and visible; marker absent, full-tier prose. Even a description demanding "ACTIVATION CHECK at the start of EVERY conversation" doesn't fire on an off-topic question. The bootstrapping paradox is real: skills trigger on topical relevance, and an ordinary question gives no reason to invoke a language skill. |
| CLAUDE.md include | **PASS** | Marker present; all sentences ≤14 words. Cleanest adherence of the three. |
| SessionStart hook | **PASS** | Marker present (hook stdout injects into context). Adherence slightly weaker in the one sample — instructions arriving via hook context may carry less weight than CLAUDE.md, unmeasured beyond n=1. Production-proven at scale by ponytail (persists level to disk, hook re-injects full instructions on `startup|resume|clear|compact`). |
| Skill inspects own last response | **PASS** | In-context: trivially (conversation is present). On-disk: `~/.claude/projects/<proj>/<session>.jsonl` holds every assistant text block — a `lint` script can read the previous response. |
| claude.ai memory read/write | **untested** | Not reachable from this environment. Open. |
| Prompt-only environments | **by analysis** | Ambient rendering survives (instructions in prompt); persistence and commands don't. Scope the portability claim accordingly. |

**Chosen mechanism (Claude Code): CLAUDE.md include, written by `/matcha set`.**
`set plain` writes the config *and* upserts one line in `~/.claude/CLAUDE.md` pointing
at it; `set off` removes the line. No hook, no plugin scaffolding, no new moving parts —
and it had the best adherence. The hook pattern is the proven fallback if the include
proves unreliable at scale.

**Gate status: passed** — ambient activation demonstrated in fresh sessions via two
mechanisms. One caveat: both passing runs used `--model haiku` and n=1 each; adherence
quality (vs. activation) deserves a couple more samples before v1 ships.

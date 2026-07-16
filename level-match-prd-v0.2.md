# PRD — `level-match` (v0.2)
**A skill that adapts wording, explanation depth, terminology support, and framing for a declared audience — without introducing unsupported claims, and reporting conflicts instead of silently dropping information.**
Working name `level-match`; final name via `naming-things` before publishing.
Status: Draft v0.2 · Owner: Jayson · Supersedes v0.1
v0.2 changes: fidelity invariant added (Invariant #0); purpose promoted into v1 as an internal task frame; four-stage pipeline; all examples rebuilt from explicit source fact sets; checker reframed as advisory linguistic lint; three-layer evaluation; proficiency inference cut from v1; platform spike promoted to v0.
---
## 1. Core contract
> `level-match` adapts wording, explanation depth, terminology support, and framing for a declared audience. It preserves task-critical facts, numbers, qualifications, and uncertainty, and does not introduce claims unsupported by the source. When a requested language constraint conflicts with faithful communication, it reports the conflict instead of silently dropping information.
Three properties, kept separate and tested separately:
| Property | Definition | Tested by |
|---|---|---|
| **Correctness** | No claim in the output is unsupported by the source fact set | fidelity eval (forbidden-additions check) |
| **Completeness** | All facts required for the reader's *purpose* survive, including numbers, qualifications, and uncertainty markers | fidelity eval (required-facts checklist) |
| **Relevance** | Facts not required for the purpose may be omitted; rendering matches the declared tiers | rubric eval + lint |
"Same information at every tier" (v0.1) was untestable and self-contradictory — tiers legitimately change what is shown. The testable replacement: **tiers change rendering; purpose changes selection; nothing changes truth.**
---
## 2. Pipeline
```
source truth  →  purpose selection  →  conceptual framing  →  linguistic realization
  (facts)         (which facts)         (how framed)            (how phrased)
```
Every rendering starts from an explicit or reconstructable **source fact set**. Without stage 1 and 2, "information preservation" is undefined — you cannot know whether an omission is calibration or loss.
### 2.1 Internal task frame (v1, no UI)
Populated per-request from context and phrasing; overridable in one line ("this is for the auditor"):
```text
audience:        who will read this
purpose:         understand | decide | act | review
source_facts:    claims that may be used (from the artifact/conversation)
required_facts:  claims that must survive for this purpose
```
Purpose is the only dimension besides the two tiers that changes *which facts appear* (v0.1 §4.4 already demonstrated this without admitting it). v1 carries it as an internal frame; a user-facing third axis remains v2.
---
## 3. The two axes
| Axis | Question | Persistence | Inspiration (loose, non-conformant) |
|---|---|---|---|
| **Linguistic** | Can the reader parse the English? | Persistent preset — a property of the reader | CEFR bands, frequency-list research |
| **Conceptual** | Does the reader know the domain? | Per-request — a property of this artifact's audience | Dreyfus (ladder shape), CLT/expertise-reversal (rendering rules) |
Orthogonality is the founding observation. Off-diagonal audiences are real: **basic × expert** (L2 engineer — knows what a rollback is, doesn't want deep nesting), **full × novice** (fluent executive — rich English, no infrastructure knowledge). Conflating the axes either patronizes the engineer or drowns the non-engineer in easy words arranged around concepts they don't have.
**Glossing is the only bridge:** at lower linguistic tiers, domain terms that must appear (because removal breaks completeness) get a one-line inline definition on first use.
---
## 4. Tiers
### 4.1 Linguistic presets (persistent: `basic` / `plain` / `full`)
Described as **writing presets informed by CEFR and readability research** — no conformance claim. Names signal *language*, not intelligence.
| Preset | Vocab guideline | Sentence limit | Grammar ceiling | Idioms | Glossing |
|---|---|---|---|---|---|
| **basic** | ~1,000 headwords (NGSL-informed) | max 14 words, p90 ≤ 12 | simple clauses; and/but/because; simple if/when | none | every domain term, first use |
| **plain** | ~2,000–3,500 | max 20, p90 ≤ 16 | passives, relatives, conditionals; moderate nesting | high-frequency phrasals only | obscure terms only |
| **full** | uncapped | — | unrestricted | natural | none |
| *(unset)* | skill inert | — | — | — | — |
Changes from v0.1 (per review):
- **No lower bounds on sentence length.** A clear 8-word sentence never fails `basic`. Limits are maxima + 90th percentile.
- **Vocabulary is an advisory guideline, not a hard gate.** Out-of-list tokens are lint findings, thresholded at `max(1% of tokens, 3 tokens)`, after excluding proper nouns, product names, acronyms, code identifiers, and the per-conversation gloss allowlist; matching is lemma-based.
- **Gloss density ceiling.** If faithful rendering at the requested preset would require glossing beyond ~1 term per 2 sentences, the skill does not gloss-bomb: it restructures (summary first, terms introduced progressively) or **reports the conflict** — "this material cannot be rendered faithfully at `basic`; here is the closest faithful version, and here's what couldn't be simplified."
Register rule unchanged: simple English is not childish English (GOV.UK as the register model — complex content in plain language that never infantilizes). No cheeriness inflation. Shorter paragraphs at lower presets.
Neutral fallback when a user asks for "simpler" language with no preset configured: **`plain`**, applied as a preset choice — not as a judgment of the user's proficiency.
### 4.2 Conceptual modes (per-request: `novice` / `familiar` / `expert`)
The design metaphor stands — expertise changes which objects exist for the reader (Dreyfus) — but v0.2 operationalizes it as an **allowed-operations table**. Given the source fact set, each mode permits specific transformations:
| Operation | Definition | novice | familiar | expert |
|---|---|---|---|---|
| **state-effect** | render a fact as its outcome for the reader | required framing | allowed | allowed |
| **omit-mechanism** | drop *how*, keep *what/why* — only if mechanism ∉ required_facts | default | allowed | not default |
| **summarize-mechanism** | compress how it works to one clause | allowed | default | allowed |
| **name-pattern** | use the domain term/pattern name as the carrier | forbidden without gloss | with one-line context | default |
| **gloss** | inline one-line definition on first use | all terms | obscure terms | none |
| **analogize** | map to an everyday schema | allowed, must be flagged as analogy if it could be mistaken for fact | on request | **no unsolicited teaching analogies** |
| **show-internals** | parameters, edge cases, tradeoffs | forbidden unless ∈ required_facts | on request | default |
Boundary definitions (previously intuitions):
- A **mechanism** is any causal step between an action in the source and its stated effect.
- An **internal** is any parameter or implementation choice not needed to predict the effect.
- A fact is **hideable** iff it is not in `required_facts` for the declared purpose. This is the rule that makes "novice explanation" distinguishable from "incomplete explanation": the purpose frame, not the mode, decides what must survive.
CLT-derived rules, restated at the strength the literature supports: unsolicited instructional scaffolding harms readers who already hold the schema (expertise-reversal) — hence *no unsolicited teaching analogies* at expert, and pre-filtered mechanism at familiar. Uncertainty tie-breaks: conceptual mode rounds **down but compressed** (a brief plain rendering costs an expert seconds; an expert rendering transfers nothing to a novice).
**Honest ceiling (kept from the review exchange):** the conceptual axis cannot be operationalized symmetrically with the linguistic axis — no governed standard, no calibrated instruments, domain-specific all the way down. The operations table constrains the renderer; *evaluation* of conceptual appropriateness is rubric-based with per-domain examples (layer 2, §7), not deterministic.
### 4.3 "Simplify" and friends
Unqualified adaptation requests ("simplify", "dumb it down", "make it accessible") are **ambiguous one-shot adaptations** — users may mean shorter sentences, less jargon, less detail, or all three. Behavior: apply a moderate adjustment on both axes for that response, state the interpretation in half a sentence when ambiguity is high ("keeping the numbers, dropping the mechanism — say 'simpler English' if you meant the wording"), and **never mutate persistent settings** (Invariant #4).
---
## 5. Worked examples (rebuilt)
Every example now begins from an explicit source fact set. Cells may omit, reorganize, explain, or qualify these facts — never add.
### 5.1 PR summary — Redis caching
**Source fact set** (from the PR diff + description):
- F1: a Redis cache was added to the `/auth/token` endpoint
- F2: cache TTL is 5 minutes
- F3: on cache miss, the existing database path is used (fallback preserved)
- F4: cache entries are invalidated on password change
- F5: stated motivation: reduce database load and login latency (*intended*, not measured)
Task frame: `audience: per cell · purpose: understand · required_facts: F1, F5 (+F4 for any audience that could act on stale-auth risk)`
| | **novice** | **familiar** | **expert** |
|---|---|---|---|
| **basic** | "Logins should get faster. The app now saves recent login checks for a short time, so it does not repeat slow work. If you change your password, the saved check is cleared." | "We added a cache (a fast, short-term memory store) for login checks. Repeat logins can skip the database for up to 5 minutes. A password change clears the cached entry." | "Added Redis cache on `/auth/token`. TTL 5 min. DB path kept as fallback on miss. Invalidation on password change. Goal: lower DB load and login latency." |
| **plain** | "Login speed should improve. The system now keeps recent login results on hand for a few minutes instead of recomputing them each time. Changing your password clears the stored result, so old credentials can't be reused." | "Auth responses are now cached in Redis for 5 minutes, so repeated logins skip the database lookup. Cache entries are invalidated on password change, and the database path remains as fallback. This should reduce DB load and login latency." | "Redis cache added on `/auth/token`, 5-min TTL, DB fallback on miss, invalidation on password change. Motivation: DB load and p-latency reduction — intended, not yet measured." |
| **full** | "Login latency should drop: the endpoint now retains recent verification results for five minutes rather than recomputing them on every request. A password change immediately clears the retained result, so revoked credentials cannot ride on a stale entry." | "The auth endpoint now employs a Redis-backed cache (5-minute TTL) that eliminates redundant database round-trips for repeat authentications; entries are invalidated on password change and the database path is preserved as fallback." | "Introduced a Redis cache on `/auth/token`: 5-min TTL, database fallback on miss, invalidation on credential change. Expected effect is reduced DB load and login latency; no benchmark accompanies the PR." |
What changed vs. v0.1: no jitter, no singleflight, no p99 number, no "cache-aside" (the source doesn't name the pattern — expert cells describe the behavior instead of naming an unconfirmed pattern). "Faster" is everywhere qualified ("should"), because F5 is an intention. Note the qualification survives *even at basic × novice* — uncertainty markers are required facts.
### 5.2 Financial — loan top-up (purpose changes selection)
**Source fact set** (from the borrower's agreement + bank's offer letter):
- F1: existing hire-purchase loan, variable rate, currently 22.31%
- F2: top-up offer consolidates outstanding balance + new advance into one loan
- F3: the repayment term resets on acceptance
- F4: monthly instalment under the top-up is close to the current instalment
- F5: a full settlement figure is available from the bank on request
**Purpose = decide** (accept the top-up or not) → required: F1–F5, especially F3 (term reset drives total cost) and F5 (the action).
*plain × familiar, purpose=decide:*
> "The top-up combines what you still owe with the new money into one loan, and the repayment term starts over. Because the term resets, you pay interest on the combined balance for longer — so even though the monthly instalment looks close to what you pay now, the total interest over the life of the loan rises. The rate is variable, currently 22.31%, so this total can also move. Before deciding, ask the bank for the full settlement figure and compare total cost, not monthly cost."
*basic × novice, purpose=decide:*
> "A top-up adds new money to your old loan. The loan then starts again from month one. You pay for more months, so the total interest goes up — even if the monthly payment looks the same. The interest rate can change over time. It is 22.31% now. Before you say yes, ask the bank for the full amount you would pay to close the loan. Compare the total cost, not the monthly cost."
**Purpose = understand** (how top-ups work, no pending decision) → F5 drops out of required; F4 becomes illustrative. Same tiers, smaller required set. This pair is the demonstration that completeness is purpose-relative: omitting F5 is *calibration* under `understand` and *loss* under `decide`.
### 5.3 Medical — gloss knob (axes are orthogonal)
**Source fact set:** F1: biopsy result is benign · F2: follow-up imaging in six months is recommended.
*basic, gloss=auto (L2 patient):*
> "The test took a small piece of tissue (a biopsy). The result is benign — this means it is not cancer. The doctor recommends one more scan in six months."
*basic, gloss=off (L2 doctor):*
> "Biopsy: benign. Recommended follow-up imaging at six months."
Same preset, same two facts, different output — the proof that language level and domain knowledge are independent knobs. (v0.1's "may still check it again to be safe" is gone: F2 is a recommendation with a timeframe, and both survive verbatim in content.)
### 5.4 Incident summary — purpose selecting facts
**Source fact set** (from the postmortem notes):
- F1: `payments-worker` was OOMKilled repeatedly, 02:10–02:40 EAT
- F2: users experienced slow responses in that window
- F3: root cause: unbounded retry queue growing after upstream 503s
- F4: mitigation applied: memory limit raised 512Mi → 1Gi; service stable since
- F5: planned fixes: bounded queue, jittered backoff, restart-rate alert
*purpose=understand, plain × familiar (status page):* required = F1(time), F2, F4(stable)
> "One of our services ran out of memory and restarted repeatedly between 02:10 and 02:40. Some users saw slow responses during that window. We increased the service's memory and it has been stable since. Longer-term fixes are planned."
*purpose=review, full × expert (postmortem):* required = F1–F5
> "`payments-worker` OOMKilled in a crash loop 02:10–02:40 EAT. Root cause: an unbounded retry queue grew without limit after upstream 503s. Mitigation: memory limit raised 512Mi→1Gi; stable since. Fixes: bound the queue, add jittered backoff, alert on restart rate."
Same source, different fact selection — driven by `purpose`, not by either tier.
### 5.5 Constraint collision — the reporting behavior
Request: render a variable-rate clause with a compounding-in-arrears definition at `basic`, purpose=decide.
> "I can't fully express this clause at the basic language level without losing legally important detail. Here is the closest faithful version:
> 'The interest rate can change. The bank works out interest daily and adds it to what you owe [compounding — interest charged on top of earlier interest]. …'
> **Not simplified:** the exact definition of the reference rate and the fallback provision — these need the original wording. Want them quoted as-is with plain-language notes alongside?"
Collision handling is a first-class output, not a failure: the contract's last sentence in operation.
---
## 6. Settings, activation, platform
### 6.1 v1 settings — explicit only
```yaml
# ~/.claude/level-match.md (Claude Code)  |  memory entry (claude.ai, capability-dependent)
preset: plain        # basic | plain | full | (absent = inert)
gloss: auto          # auto | off
fk_pin: null         # null | 1–13 — compliance pin (power feature, docs-only)
```
**Cut from v1: proficiency inference.** Writing-based estimation is confounded by short messages, mobile typing, translation tools, fatigue, disability, and code-switching (a particularly live confound in multilingual markets), and the v0.1 IRT framing added scientific language without calibrated items. v1 is explicit-settings-only; at most, the skill may *offer once*: "Want me to keep my English at a set level? You can pick basic / plain / full." Correct use of a term suppresses **that term's gloss locally** — it updates no general estimate.
`fk_pin` semantics (unchanged in substance, demoted in prominence): preset keeps driving vocabulary/grammar/idioms/gloss; the pin makes the FK-grade lint finding blocking at the pinned value, for compliance cases where the requirement is written as a grade level. Revision strategy on FK failure: shorter sentences and Germanic word swaps — never stripped connectives (the degenerate path to passing FK). Conflict between pin and preset → pin wins on the metric, skill warns once.
### 6.2 Platform spike = v0 (before any other build)
The v0.1 architecture assumed one portable SKILL.md provides ambient activation, slash commands, local persistence, deterministic post-checks, and claude.ai memory editing. These are different platform capabilities. v0 proves, per platform:
| Question | Risk if wrong |
|---|---|
| Does a persistent setting reliably cause the skill to activate in *later* conversations? (Bootstrapping: an inert-until-configured skill must still load to discover its config — candidate mechanisms: CLAUDE.md include, hook, always-on trigger description) | the entire ambient premise |
| Can the skill inspect its own last response for `rewrite`/`lint`? | two of three core commands |
| How do slash commands invoke a script and surface its report? | lint loop |
| Can claude.ai memory be read/written as assumed? | claude.ai persistence |
| What survives in prompt-only environments? | portability claim |
Deliverable: a capability matrix + the chosen activation mechanism per platform. **Interface commitments wait for this.**
### 6.3 Command surface (v1, post-spike)
| Command | Does |
|---|---|
| `/level-match rewrite basic` | one-shot re-render of supplied or previous text at a preset |
| `/level-match lint` | advisory lint report on the last response |
| `/level-match set plain` | declare preset (`set off` disables) |
| `/level-match` | status: preset, gloss list this conversation, pin |
Ambient behavior needs no command; commands are the control surface.
---
## 7. Evaluation — three layers
The v0.1 checker overclaimed. `lint_level.py` (renamed from `check_level.py`) is a **linguistic lint tool producing advisory findings**, not enforcement of level-matching.
| Layer | Mechanism | Verifies | Cannot verify |
|---|---|---|---|
| **1. Deterministic lint** | stdlib script | sentence maxima/p90, out-of-list vocabulary flags (lemma-matched, allowlisted), FK grade, nominalization-suffix density, connective density, code-block exclusion | anything semantic |
| **2. Model-based rubric** | judge prompts, per-domain examples | conceptual-mode appropriateness (allowed-operations table), analogy quality and flagging, register/patronizing tone, grammar-ceiling adherence, gloss correctness | ground truth |
| **3. Source-grounded fidelity** | per-case fact checklists | required facts present (incl. numbers, qualifications, uncertainty markers verbatim in content), **forbidden additions absent** (any claim outside the source set fails), collision reported when required | — |
Dropped from lint claims: pronoun-reference resolution (not realistically enforceable in a small stdlib script; at most a heuristic distance flag, layer-2 verified), "user used a term correctly" (layer 2), tone (layer 2).
Test suite: matrix sweep (domains × presets × modes × purposes) through all three layers; negative tests — no activation on terse-but-fluent input, code blocks untouched, "simplify" never mutates settings, expert mode contains no unsolicited teaching analogies, collision cases produce reports rather than silent omission; register screen on basic-preset output.
---
## 8. Invariants (consolidated, v0.2)
0. **Never introduce an unsupported factual claim.** Calibration may omit, reorganize, explain, or qualify source claims — only that. (Supersedes and grounds v0.1's Invariant #1.)
1. Preserve all task-critical facts, numbers, qualifications, and uncertainty for the declared purpose; omission is legitimate only for facts outside `required_facts`.
2. Code, commands, error messages, and quoted material are never calibrated.
3. When constraint and fidelity collide, report the conflict; never silently drop required information.
4. Per-request adaptation ("simplify" etc.) never mutates persistent settings.
5. No unsolicited teaching analogies at expert mode; analogies that could be mistaken for fact are flagged as analogies at every mode.
6. FK-pin failures are revised by shortening sentences and swapping Latinate for Germanic words — never by stripping connectives.
7. A term glossed once per conversation is not re-glossed; a term the user uses is not glossed — with no wider inference drawn.
8. Simple English is not childish English: GOV.UK register, no cheeriness inflation.
9. No proficiency judgment is attached to any user; presets are writing choices, and the neutral fallback is `plain`.
---
## 9. Scope
### v1 (narrowed per review)
Explicit settings only · `basic`/`plain`/`full` as writing presets (no CEFR conformance claim) · conceptual mode explicit or inferred-from-request with one-line override · internal purpose frame · one-shot `rewrite` of supplied text · advisory lint · source-grounded fidelity eval in the test suite · collision reporting · **no guarantee that arbitrary content can meet every preset** — that's what the collision report is for.
### Non-goals (v1)
Proficiency inference/assessment (cut; ecosystem tools exist) · teaching loops (cefr-reading-coach, fluent) · correcting the user's English (lang-tutor) · user-facing purpose axis (internal frame only) · non-English targets · verbosity, register, structure, stance (owned elsewhere or out of scope).
### v2 candidates
User-facing purpose axis (the one future dimension that changes fact selection) · locale/cultural field extending the linguistic rule tables · per-project conceptual-mode defaults · consensual assessment as an explicit opt-in command, if the spike shows it can be done without silent profiling.
---
## 10. Phasing
| Phase | Contents | Gate to proceed |
|---|---|---|
| **v0 — platform spike** | activation/bootstrapping mechanism per platform; last-response inspection; command→script wiring; claude.ai memory capabilities; prompt-only fallback | capability matrix written; activation works across ≥2 sessions |
| **v0.5 — fidelity harness** | fact-checklist eval format + 5 seed cases (the §5 examples); `lint_level.py` | forbidden-addition detection catches seeded violations |
| **v1** | SKILL.md (presets, modes, operations table, purpose frame, invariants); `rewrite`, `lint`, `set`; persistence per spike findings | full three-layer suite green on matrix sweep |
| **v1.1** | `fk_pin`, status command, gloss-density collision handling polish | — |
| **v2** | purpose axis UI, locale, project defaults | — |
Build-order rationale: the spike de-risks the premise; the fidelity harness de-risks the contract; only then is the renderer worth writing.
## 11. Risks
| Risk | Mitigation |
|---|---|
| Renderer hallucinates plausible detail at higher modes | Invariant #0 + layer-3 forbidden-additions eval (the v0.1 examples themselves failed this — now the seed test cases) |
| Platform can't support ambient activation | v0 spike before interface commitments; degrade to explicit-invocation tool if needed |
| Completeness undefined in practice | purpose frame + per-case `required_facts`; collision report when unmeetable |
| Goodhart on FK | advisory-by-default; pin is opt-in; revision-strategy invariant #6 |
| Patronizing output at `basic` | register model + layer-2 screen |
| Gloss-bombing dense material | density ceiling → restructure or collision report |
| Scope creep into styles territory | ownership table (v0.1 §7, unchanged in substance); non-goals |
---
## Appendix — literature (condensed; loose inspirations, not conformance)
CEFR: band structure and the scale users know themselves by. Nation / NGSL / Oxford 3000: frequency-list mechanism (challenge target inverted: comprehension, not acquisition). Flesch-Kincaid: two-variable proxy; instrument and disagreement-detector, never objective. Coh-Metrix line of research: connective deletion lowers comprehension while improving FK — the failure mode Invariant #6 guards. Dreyfus: ladder shape and objects-perception insight, adapted from performance to comprehension; cited as lineage. Sweller/Kalyuga (CLT, expertise-reversal): unsolicited scaffolding harms schema-holders — the empirical basis for mode-dependent rendering, stated at supported strength. GOV.UK / ISO 24495-1: existence proof and process posture for plain language.

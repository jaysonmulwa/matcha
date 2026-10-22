# `matcha`

```text
                             ) )
                            ( (
                         .---------.
                         |         |\     █▀▄▀█ ▄▀▀▄ ▀▀█▀▀ ▄▀▀▀ █  █ ▄▀▀▄ 
                         |         | |    █ ▀ █ █▄▄█   █   █    █▀▀█ █▄▄█
                         |         | |    ▀   ▀ ▀  ▀   ▀   ▀▀▀▀ ▀  ▀ ▀  ▀
                         |         |/
                          \_______/              抹 茶
```

*For when you don't follow what Claude just told you about your own PR.*

A Claude Code skill that adapts how Claude writes for you: the level of English, the
domain knowledge it assumes, and the amount of professional jargon — never the facts.

## Install

**Claude Code** — from the CLI (or in a session, drop `claude` and use `/plugin …`):

```bash
claude plugin marketplace add jaysonmulwa/matcha
claude plugin install matcha@matcha
```

Adds `/matcha:matcha`. A SessionStart hook applies your level each session;
`/plugin update` keeps it current.

**Or copy it by hand** — commands stay bare `/matcha`, and you update it yourself:

```bash
git clone https://github.com/jaysonmulwa/matcha
cp -r matcha/skills/matcha ~/.claude/skills/
```

<details>
<summary>Codex, Cursor, Windsurf, Cline, Kiro, Gemini, OpenCode</summary>

These get matcha's **request-driven half** only — the grid, the five levels, the
fidelity rules. The *persistent* level (`set`) is Claude-Code-only; here you name the
level per request. Rules are one shared body (`AGENTS.md` canonical, vendor files
mirror it).

**Codex** — from the CLI:

```bash
codex plugin marketplace add jaysonmulwa/matcha
codex plugin add matcha@matcha
```

**Others** — copy the file your tool reads into your project:

| Tool | File |
|---|---|
| Cursor | `.cursor/rules/matcha.mdc` |
| Windsurf | `.windsurf/rules/matcha.md` |
| Cline | `.clinerules/matcha.md` |
| Kiro | `.kiro/steering/matcha.md` |
| Gemini CLI · OpenCode | `AGENTS.md` |
</details>

## Use

```
/matcha set plain          # any of the five levels — persists across sessions
/matcha rewrite familiar   # one-shot, config untouched
/matcha status             # check what's configured
/matcha set off            # remove everything it wrote
/matcha plain 4            # one-shot at plain, exactly 4 sentences
/matcha plain 4-6          # one-shot at plain, 4 to 6 sentences
/matcha plain 3l           # one-shot at plain, 3 lines
/matcha 4-6                # configured level, 4 to 6 sentences
/matcha rewrite plain 4-6  # re-render the last answer, budgeted
```

(Prefix with `matcha:` if you installed the plugin — `/matcha:matcha set plain`.)

Inert until you `set` a level. `set` writes two files: `~/.claude/matcha.md` and a
marker-delimited block in `~/.claude/CLAUDE.md`. Nothing outside the markers is
touched, and `set off` removes both.

No level needed for one-shots — just ask: *"simplify this"*, *"rewrite for my exec"*.

## Size budget

Add a count or a range to any request and the answer stays inside it — at the level,
with no new facts. It never changes the saved level. In the slash form it is a trailing
token: `4` (exactly four sentences), `4-6` (a range), `3l` (three lines).

```
Using matcha plain, in 4-6 sentences, explain this issue and solution.
```

> The app skipped some uploads because one worker took longer than the limit. Each
> upload has a timeout, and this worker hit it while a backup job was running. The
> fix raises the timeout for uploads above 50 MB, so slow ones are not thrown away.
> Smaller uploads keep the old limit. This should stop the skipped uploads, but the
> change has not yet been measured in production.

Five sentences, every one under 20 words, and "should" stays because the source said
*intended*. Code, quotes and glosses are not counted. If the budget cannot hold the
facts, the skill says so and gives the closest version that fits — it never pads to
reach a count and never drops a fact to hit one.

## The five levels

| Level | English | Domain framing |
|---|---|---|
| `basic` | ≤14 words/sentence, ~1,000 common words | mechanisms explained, every term glossed |
| `plain` | ≤20 words/sentence, everyday vocabulary | mechanisms explained, obscure terms glossed |
| `full` | uncapped | mechanisms explained, terms glossed |
| `familiar` | uncapped | mechanism in one clause |
| `expert` | uncapped | terms used directly, internals shown, terse, no analogies |

Your default sits around `familiar`.

## The grid

The grid is the idea the whole skill rests on. Two knobs, independent of each other:

- **linguistic** — can the reader parse the English?
- **conceptual** — do they know the domain?

**Across, conceptual difficulty rises.** **Down, linguistic difficulty rises.** The
five levels are an L-shaped path through the grid — ①②③ raise the English, ③④⑤ drop
the hand-holding.

| | novice | familiar | expert |
|---|---|---|---|
| **basic** | ① `basic` | · | · |
| **plain** | ② `plain` | · | · |
| **full** | ③ `full` → | ④ `familiar` → | ⑤ `expert` |

The `·` cells are real, just off the ladder: low English, high domain knowledge — an
L2 engineer who wants short sentences and no hand-holding. Ask for them in words:
*"short sentences, but assume I know Kubernetes."*

### One statement, all nine cells

The grid below renders the same PR summary in every cell — across, the reader is
assumed to know more; down, the English gets harder.

> A Redis cache on `/auth/token`, TTL 5 minutes, DB fallback on miss, invalidated on
> password change, *intended* to cut DB load and latency (not measured).

| | **novice** | **familiar** | **expert** |
|---|---|---|---|
| **basic** | "Logins should get faster. The app now saves recent login checks for a short time, so it does not repeat slow work. If you change your password, the saved check is cleared." | "We added a cache (a fast, short-term memory store) for login checks. Repeat logins can skip the database for up to 5 minutes. A password change clears the cached entry." | "Added Redis cache on `/auth/token`. TTL 5 min. DB path kept as fallback on miss. Invalidation on password change. Goal: lower DB load and login latency." |
| **plain** | "Login speed should improve. The system now keeps recent login results on hand for a few minutes instead of recomputing them each time. Changing your password clears the stored result, so old credentials can't be reused." | "Auth responses are now cached in Redis for 5 minutes, so repeated logins skip the database lookup. Cache entries are invalidated on password change, and the database path remains as fallback." | "Redis cache added on `/auth/token`, 5-min TTL, DB fallback on miss, invalidation on password change. Motivation: DB load and p-latency reduction — intended, not yet measured." |
| **full** | "Login latency should drop: the endpoint now retains recent verification results for five minutes rather than recomputing them on every request. A password change immediately clears the retained result, so revoked credentials cannot ride on a stale entry." | "The auth endpoint now employs a Redis-backed cache (5-minute TTL) that eliminates redundant database round-trips for repeat authentications; entries are invalidated on password change and the database path is preserved as fallback." | "Introduced a Redis cache on `/auth/token`: 5-min TTL, database fallback on miss, invalidation on credential change. Expected effect is reduced DB load and login latency; no benchmark accompanies the PR." |

### Walking one concept down the ladder

The grid above shows every cell at once. This shows the exact commands — start strict,
then get easier. Explaining Byzantine fault tolerance: *keeps a system correct when
some parts fail or lie · needs more than two-thirds of parts honest (the `3f+1` rule) ·
used in blockchains and flight control.*

```
/matcha set expert
```
> BFT: consensus under arbitrary node behavior, not just crash-stop. Safety holds for `f` faulty of `n ≥ 3f+1` (the PBFT bound). Contrast Raft/Paxos, which assume `n ≥ 2f+1` and no lying.

```
/matcha rewrite plain
```
> Byzantine fault tolerance lets a distributed system agree even when some nodes fail arbitrarily — crashing, or sending conflicting information. It tolerates up to `f` bad nodes given at least `3f+1` total, i.e. over two-thirds honest.

```
/matcha rewrite basic
```
> Byzantine fault tolerance keeps a system working when some parts fail or lie. Think of generals who must agree while some send false orders. *(That's an analogy, not the real thing.)* The honest parts still reach one decision — as long as more than two-thirds stay honest.
>
> **Couldn't simplify:** the exact rule `n ≥ 3f+1` and the names PBFT / Raft / Paxos — kept as-is rather than rounded into something false.

The analogy shows up only at `basic` and is flagged; `n ≥ 3f+1` survives as a formula
until `basic`, where it's named as held-back rather than faked into "most parts" (which
would be wrong — the bound is *two-thirds*, not half).

<details>
<summary>Related literature</summary>

Loose inspirations, not conformance claims — each taken narrower than the source.
Full notes in the [PRD appendix](./docs/prd-v0.2.md#appendix--literature-condensed-loose-inspirations-not-conformance).

| Source | What we took |
|---|---|
| [**CEFR**](https://www.coe.int/en/web/common-european-framework-reference-languages) | The band structure, and the scale L2 readers already know themselves by. Levels are "CEFR-informed", never CEFR-conformant. |
| [**NGSL**](https://www.newgeneralservicelist.com/) · [**Oxford 3000**](https://www.oxfordlearnersdictionaries.com/wordlists/oxford3000-5000) | Word-frequency lists as the vocabulary mechanism — inverted: they target *acquisition* (stretch the learner); we target *comprehension* (stay in range). |
| [**Flesch-Kincaid**](https://en.wikipedia.org/wiki/Flesch%E2%80%93Kincaid_readability_tests) | A two-variable readability proxy. An instrument and a disagreement-detector, never ground truth. |
| [**Coh-Metrix**](https://en.wikipedia.org/wiki/Coh-Metrix) | The negative result: deleting connectives ("because", "so") *improves* FK while *lowering* comprehension. Shorten sentences; never strip connectives. |
| [**Dreyfus**](https://en.wikipedia.org/wiki/Dreyfus_model_of_skill_acquisition) | Expertise changes *which objects exist* for the reader — a novice sees steps, an expert sees "a rollback". Lineage, not authority. |
| [**Expertise reversal**](https://en.wikipedia.org/wiki/Expertise_reversal_effect) (Sweller / Kalyuga) | Unsolicited scaffolding measurably harms readers who already hold the schema. Hence no unsolicited analogies at `expert`. |
| [**GOV.UK style guide**](https://www.gov.uk/guidance/style-guide) · [**ISO 24495-1**](https://www.iso.org/standard/78907.html) | The register model: complex content in plain language that never infantilizes. Simple English is not childish English. |
</details>

---

[docs/design.md](./docs/design.md) — how it's built, what it can't do.
[skills/matcha/SKILL.md](./skills/matcha/SKILL.md) is the canonical source; an
installed copy under `~/.claude/skills/` is a deployment of it.

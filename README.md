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

In Claude Code:

```
/plugin marketplace add jaysonmulwa/matcha
/plugin install matcha@matcha
```

Plugin skills are namespaced, so the commands are `/matcha:matcha …`. A bundled
SessionStart hook activates your level each session — no CLAUDE.md editing, and
`/plugin update` keeps it current.

<details>
<summary>Or copy the skill by hand — shorter commands, manual updates</summary>

```bash
git clone https://github.com/jaysonmulwa/matcha
cp -r matcha/skills/matcha ~/.claude/skills/
```

(Copy the whole `matcha/` skill directory — `SKILL.md` plus `levels/`, which
holds the activation rules `set` reads.)

Installed this way the commands are `/matcha …`, with no namespace. Activation uses a
CLAUDE.md block instead of the hook (a manual copy can't ship one). Use
`.claude/skills/matcha/` instead to scope it to one project.
</details>

<details>
<summary>Other tools — Codex, Gemini, Cursor, Windsurf, Cline, Kiro, OpenCode</summary>

Every tool below gets the **request-driven half**: the grid, the five levels, and the
fidelity rules. *"Explain this for my exec"*, *"rewrite that at basic"* work anywhere.
What does **not** port is the *persistent* level — `set` relies on Claude Code hooks —
so in these tools you name the level per request. The rules are one shared body,
carried in each tool's own config file (`AGENTS.md` is canonical; the vendor files
mirror it verbatim).

| Tool | How | File it reads |
|---|---|---|
| **Codex** | `codex plugin marketplace add jaysonmulwa/matcha` then `codex plugin add matcha@matcha` — or just drop `AGENTS.md` in your project | `AGENTS.md` |
| **Gemini CLI** | copy `gemini-extension.json` + `AGENTS.md` into the project | `AGENTS.md` |
| **OpenCode** | copy `AGENTS.md` into the project | `AGENTS.md` |
| **Cursor** | copy `.cursor/rules/matcha.mdc` into your project's `.cursor/rules/` | `.cursor/rules/matcha.mdc` |
| **Windsurf** | copy `.windsurf/rules/matcha.md` into `.windsurf/rules/` | `.windsurf/rules/matcha.md` |
| **Cline** | copy `.clinerules/matcha.md` into `.clinerules/` | `.clinerules/matcha.md` |
| **Kiro** | copy `.kiro/steering/matcha.md` into `.kiro/steering/` | `.kiro/steering/matcha.md` |

The quickest way to get all of them: `git clone` the repo and copy the file(s) your
tool reads. They're small and self-contained.
</details>

## Use

```
/matcha set plain          # any of the five levels — persists across sessions
/matcha rewrite familiar   # one-shot, config untouched
/matcha status             # check what's configured
/matcha set off            # remove everything it wrote
```

(Prefix with `matcha:` if you installed the plugin — `/matcha:matcha set plain`.)

Inert until you `set` a level. `set` writes two files: `~/.claude/matcha.md` and a
marker-delimited block in `~/.claude/CLAUDE.md`. Nothing outside the markers is
touched, and `set off` removes both.

No level needed for one-shots — just ask: *"simplify this"*, *"rewrite for my exec"*.

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

## Related literature

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

---

[docs/design.md](./docs/design.md) — how it's built, what it can't do.
[skills/matcha/SKILL.md](./skills/matcha/SKILL.md) is the canonical source; an
installed copy under `~/.claude/skills/` is a deployment of it.

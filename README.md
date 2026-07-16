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

```bash
mkdir -p ~/.claude/skills/matcha
cp skill/matcha/SKILL.md ~/.claude/skills/matcha/
```

Then, inside Claude Code:

```
/matcha set plain          # any of the five levels — persists across sessions
/matcha rewrite familiar   # one-shot, config untouched
/matcha status             # check what's configured
/matcha set off            # remove everything it wrote
```

Inert until you `set` a level. `set` writes two files: `~/.claude/matcha.md` and a
marker-delimited block in `~/.claude/CLAUDE.md`. Nothing outside the markers is
touched, and `set off` removes both.

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

Two independent knobs: **linguistic** (can the reader parse the English?) and
**conceptual** (do they know the domain?). The five levels are an L-shaped path
through them — ①②③ raise the English, ③④⑤ drop the hand-holding.

| | novice | familiar | expert |
|---|---|---|---|
| **basic** | ① `basic` | · | · |
| **plain** | ② `plain` | · | · |
| **full** | ③ `full` → | ④ `familiar` → | ⑤ `expert` |

The `·` cells are real, just off the ladder: low English, high domain knowledge — an
L2 engineer who wants short sentences and no hand-holding. Ask for them in words:
*"short sentences, but assume I know Kubernetes."*

### One PR, nine cells

A Redis cache on `/auth/token`, TTL 5 minutes, DB fallback on miss, invalidated on
password change, *intended* to cut DB load and latency (not measured).

| | **novice** | **familiar** | **expert** |
|---|---|---|---|
| **basic** | "Logins should get faster. The app now saves recent login checks for a short time, so it does not repeat slow work. If you change your password, the saved check is cleared." | "We added a cache (a fast, short-term memory store) for login checks. Repeat logins can skip the database for up to 5 minutes. A password change clears the cached entry." | "Added Redis cache on `/auth/token`. TTL 5 min. DB path kept as fallback on miss. Invalidation on password change. Goal: lower DB load and login latency." |
| **plain** | "Login speed should improve. The system now keeps recent login results on hand for a few minutes instead of recomputing them each time. Changing your password clears the stored result, so old credentials can't be reused." | "Auth responses are now cached in Redis for 5 minutes, so repeated logins skip the database lookup. Cache entries are invalidated on password change, and the database path remains as fallback." | "Redis cache added on `/auth/token`, 5-min TTL, DB fallback on miss, invalidation on password change. Motivation: DB load and p-latency reduction — intended, not yet measured." |
| **full** | "Login latency should drop: the endpoint now retains recent verification results for five minutes rather than recomputing them on every request. A password change immediately clears the retained result, so revoked credentials cannot ride on a stale entry." | "The auth endpoint now employs a Redis-backed cache (5-minute TTL) that eliminates redundant database round-trips for repeat authentications; entries are invalidated on password change and the database path is preserved as fallback." | "Introduced a Redis cache on `/auth/token`: 5-min TTL, database fallback on miss, invalidation on credential change. Expected effect is reduced DB load and login latency; no benchmark accompanies the PR." |

Down a column the English changes; across a row the facts on the page change. Note
that *"should"* survives even at `basic × novice` — the speedup was intended, never
measured, and uncertainty is a fact.

## Related literature

Loose inspirations, not conformance claims — each taken narrower than the source.
Full notes in the [PRD appendix](./level-match-prd-v0.2.md#appendix--literature-condensed-loose-inspirations-not-conformance).

| Source | What we took |
|---|---|
| **CEFR** | The band structure, and the scale L2 readers already know themselves by. Levels are "CEFR-informed", never CEFR-conformant. |
| **Nation / NGSL / Oxford 3000** | Word-frequency lists as the vocabulary mechanism — inverted: they target *acquisition* (stretch the learner); we target *comprehension* (stay in range). |
| **Flesch-Kincaid** | A two-variable readability proxy. An instrument and a disagreement-detector, never ground truth. |
| **Coh-Metrix** | The negative result: deleting connectives ("because", "so") *improves* FK while *lowering* comprehension. Shorten sentences; never strip connectives. |
| **Dreyfus** | Expertise changes *which objects exist* for the reader — a novice sees steps, an expert sees "a rollback". Lineage, not authority. |
| **Sweller / Kalyuga (expertise reversal)** | Unsolicited scaffolding measurably harms readers who already hold the schema. Hence no unsolicited analogies at `expert`. |
| **GOV.UK / ISO 24495-1** | The register model: complex content in plain language that never infantilizes. Simple English is not childish English. |

---

[design.md](./design.md) — how it's built, what it can't do.
[skill/matcha/SKILL.md](./skill/matcha/SKILL.md) is the canonical source; an installed
copy under `~/.claude/skills/` is a deployment of it.

# ADR-0005 — SessionStart hook activates plugin installs

Status: Accepted · Date: 2026-07-16 · Owner: Jayson
Relates: v0 spike (design.md §6)

## Context

Ambient activation was a CLAUDE.md block that the interactive `set` command wrote.
That block does not travel with a plugin install: a marketplace-installed matcha
could not activate a level without the user running `set`, and `set` editing
`~/.claude/CLAUDE.md` is an invasive write to the user's global instructions that is
also orphaned if the plugin is later removed.

ponytail solves the same problem with a **SessionStart hook declared in its
`plugin.json`**. The hook is bundled, so it travels with any install and fires every
session with no config step. The v0 spike had already found a SessionStart hook works
(it passed); we chose CLAUDE.md at the time and left the hook on the shelf.

## Decision

Ship a **SessionStart hook** in the plugin (`hooks/hooks.json` → `matcha-activate.sh`
/ `matcha-activate.ps1`). On each session it:

1. reads `~/.claude/matcha.md` for the level;
2. **defers** (prints nothing) if a `<!-- matcha:start -->` block exists in
   `~/.claude/CLAUDE.md` — the manual path owns activation there;
3. otherwise prints the level's rules to stdout, which Claude Code injects into the
   session; prints nothing if no level is set (inert until configured).

`set` now branches by install type:

- **Plugin present** (`~/.claude/plugins/cache/matcha` exists) → write only
  `~/.claude/matcha.md`; the hook activates. **CLAUDE.md is never touched.**
- **Manual copy** → write the CLAUDE.md block as before (a manual skill copy cannot
  ship a hook).

## Consequences

- **Marketplace install becomes fully functional** — install, `set`, done; no
  CLAUDE.md editing, no orphaned block on uninstall.
- **The two mechanisms cannot double-inject.** `set` skips the block when the hook is
  present; the hook defers when a block is present. Either guard alone is sufficient,
  so a mis-detection is still safe.
- **Rule text now lives in three places** — `SKILL.md` (manual `set`),
  `matcha-activate.sh`, and `matcha-activate.ps1`. The five level rules are frozen;
  a header comment in each script flags the sync requirement. Not worth a shared data
  file: a manual skill copy ships only `SKILL.md` and cannot read plugin data files,
  so full de-duplication is impossible across the two install shapes.
- **Command name is unchanged.** The hook does not affect invocation: plugin installs
  are still `/matcha:matcha`, manual copies `/matcha` (ADR-0004 territory). The hook
  fixes *activation* parity, not the command namespace.
- Cross-platform: `command` (POSIX `sh`) and `commandWindows` (PowerShell), matching
  the ponytail pattern. No Node dependency.

## Alternatives rejected

- **Hook writes/edits the CLAUDE.md block itself** — invasive on every session, and
  reintroduces the orphan-on-uninstall problem the hook was meant to remove.
- **Drop the CLAUDE.md block entirely, hook-only** — breaks the manual copy, which
  cannot ship a hook. Both mechanisms are needed, one per install shape.
- **Node script (as ponytail uses)** — adds a runtime dependency for what `sh` and
  PowerShell already do.

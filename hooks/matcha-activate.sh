#!/bin/sh
# matcha SessionStart hook. Prints the configured level's rules to stdout, which
# Claude Code injects into the session. This activates a plugin install with no
# CLAUDE.md editing. The rule text is the single source in skills/matcha/levels/.

cfg="${HOME}/.claude/matcha.md"
[ -f "$cfg" ] || exit 0

# Defer to a manual CLAUDE.md activation block if one exists (avoids double-inject).
cmd="${HOME}/.claude/CLAUDE.md"
[ -f "$cmd" ] && grep -q 'matcha:start' "$cmd" 2>/dev/null && exit 0

level=$(sed -n 's/^level:[[:space:]]*//p' "$cfg" | head -n1 | tr -d '[:space:]')
[ -n "$level" ] || exit 0

f="${CLAUDE_PLUGIN_ROOT}/skills/matcha/levels/${level}.md"
[ -f "$f" ] && cat "$f"

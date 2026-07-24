#!/bin/sh
# matcha SessionStart hook. Reads the configured level and prints its rules to
# stdout, which Claude Code injects into the session. This is how a plugin
# install activates ambiently without editing CLAUDE.md.
#
# Rule text is duplicated in matcha-activate.ps1 and in SKILL.md's `set` block.
# The design is frozen; if a level's rules change, update all three.

cfg="${HOME}/.claude/matcha.md"
[ -f "$cfg" ] || exit 0

# Defer to a manual CLAUDE.md activation block if one exists (avoids double-inject).
cmd="${HOME}/.claude/CLAUDE.md"
[ -f "$cmd" ] && grep -q 'matcha:start' "$cmd" 2>/dev/null && exit 0

level=$(sed -n 's/^level:[[:space:]]*//p' "$cfg" | head -n1 | tr -d '[:space:]')

tail='This applies to normal answers, not just rewrite requests. Invoke the matcha skill for full rules.'
case "$level" in
  basic)    echo "matcha level \"basic\" is active. Every response: sentences of at most 14 words; the ~1000 most common words only; define each domain term in one short line at first use; explain mechanisms plainly; flag analogies as analogies; plain register, never childish. $tail" ;;
  plain)    echo "matcha level \"plain\" is active. Every response: sentences of at most 20 words; everyday vocabulary; define obscure terms in one short line at first use; explain mechanisms plainly; flag analogies as analogies; plain register, never childish. $tail" ;;
  full)     echo "matcha level \"full\" is active. Uncapped English; explain mechanisms plainly; gloss domain terms on first use; flag analogies as analogies. $tail" ;;
  familiar) echo "matcha level \"familiar\" is active. Uncapped English; assume domain familiarity; compress each mechanism to one clause; give terms brief context, do not gloss; analogies only on request. $tail" ;;
  expert)   echo "matcha level \"expert\" is active. Uncapped English; use domain terms directly; show internals, parameters, and edge cases; be terse; no unsolicited analogies or teaching scaffolding. $tail" ;;
  *)        exit 0 ;;
esac

# matcha SessionStart hook (Windows). Mirror of matcha-activate.sh.
# Reads the configured level and writes its rules to stdout for Claude Code to
# inject. Keep the rule text in sync with matcha-activate.sh and SKILL.md.

$cfg = Join-Path $env:USERPROFILE '.claude\matcha.md'
if (-not (Test-Path $cfg)) { exit 0 }

# Defer to a manual CLAUDE.md activation block if one exists (avoids double-inject).
$cmd = Join-Path $env:USERPROFILE '.claude\CLAUDE.md'
if ((Test-Path $cmd) -and (Select-String -Path $cmd -Pattern 'matcha:start' -Quiet)) { exit 0 }

$line = Get-Content $cfg | Where-Object { $_ -match '^level:' } | Select-Object -First 1
$level = ($line -replace '^level:\s*', '').Trim()

$tail = 'This applies to normal answers, not just rewrite requests. Invoke the matcha skill for full rules.'
$msg = switch ($level) {
  'basic'    { "matcha level `"basic`" is active. Every response: sentences of at most 14 words; the ~1000 most common words only; define each domain term in one short line at first use; explain mechanisms plainly; flag analogies as analogies; plain register, never childish. $tail" }
  'plain'    { "matcha level `"plain`" is active. Every response: sentences of at most 20 words; everyday vocabulary; define obscure terms in one short line at first use; explain mechanisms plainly; flag analogies as analogies; plain register, never childish. $tail" }
  'full'     { "matcha level `"full`" is active. Uncapped English; explain mechanisms plainly; gloss domain terms on first use; flag analogies as analogies. $tail" }
  'familiar' { "matcha level `"familiar`" is active. Uncapped English; assume domain familiarity; compress each mechanism to one clause; give terms brief context, do not gloss; analogies only on request. $tail" }
  'expert'   { "matcha level `"expert`" is active. Uncapped English; use domain terms directly; show internals, parameters, and edge cases; be terse; no unsolicited analogies or teaching scaffolding. $tail" }
  default    { '' }
}
if ($msg) { Write-Output $msg }

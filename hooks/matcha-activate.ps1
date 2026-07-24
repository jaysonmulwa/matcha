# matcha SessionStart hook (Windows). Mirror of matcha-activate.sh.
# Prints the configured level's rules to stdout for Claude Code to inject.
# Rule text is the single source in skills\matcha\levels\.

$cfg = Join-Path $env:USERPROFILE '.claude\matcha.md'
if (-not (Test-Path $cfg)) { exit 0 }

# Defer to a manual CLAUDE.md activation block if one exists (avoids double-inject).
$cmd = Join-Path $env:USERPROFILE '.claude\CLAUDE.md'
if ((Test-Path $cmd) -and (Select-String -Path $cmd -Pattern 'matcha:start' -Quiet)) { exit 0 }

$line = Get-Content $cfg | Where-Object { $_ -match '^level:' } | Select-Object -First 1
$level = ($line -replace '^level:\s*', '').Trim()
if (-not $level) { exit 0 }

$f = Join-Path $env:CLAUDE_PLUGIN_ROOT "skills\matcha\levels\$level.md"
if (Test-Path $f) { Get-Content -Raw $f }

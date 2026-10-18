#!/bin/sh
# PostToolUse hook, installed once in ~/.claude/settings.json so every project gets it.
# Tells Claude the session's real effort, so it never guesses. With a PLAN.md Model · effort
# column it compares against the next unfinished row (`default` = medium, Opus 5.5's default) and
# speaks only when the session runs below it; running above is deliberate (review skills,
# escalation). Without one it states the effort once per session. Effort comes from the hook
# input's effort.level, or $CLAUDE_EFFORT; with neither (a model without effort levels) it stays
# silent. Silent inside subagents (agent_id in the input), whose skill or agent file sets their
# effort. A missing session_id is a hook error, so a changed input format shows up.
input=$(cat)
printf '%s' "$input" | jq -e 'has("agent_id")' >/dev/null 2>&1 && exit 0
session=$(printf '%s' "$input" | jq -r '.session_id // empty') || { echo 'effort-check: input is not JSON' >&2; exit 1; }
[ -n "$session" ] || { echo 'effort-check: no session_id in hook input' >&2; exit 1; }
effort=$(printf '%s' "$input" | jq -r '.effort.level // empty')
effort=${effort:-${CLAUDE_EFFORT:-}}
[ -n "$effort" ] || exit 0
plan="${CLAUDE_PROJECT_DIR:-.}/PLAN.md"
row=
[ -f "$plan" ] && row=$(awk -F'|' '
  /^\|/ && tolower($0) ~ /model.*effort/ && tolower($0) ~ /status/ {
    for (i = 2; i < NF; i++) { h = tolower($i)
      if (h ~ /effort/) e = i; if (h ~ /status/) s = i; if (h ~ /^ *# *$/) n = i }
    next }
  e && /^\| *[0-9]/ {
    st = tolower($s); if (st ~ /done|defer|drop|cancel/) next
    v = tolower($e); gsub(/`/, "", v); sub(/.*[·\/]/, "", v)
    if (v ~ /default/) v = "medium"
    if (match(v, /xhigh|max|high|medium|low/)) { print (n ? $n : "?") "|" substr(v, RSTART, RLENGTH); exit }
  }' "$plan")
if [ -n "$row" ]; then
  num=$(printf '%s' "${row%%|*}" | tr -d ' ')
  want=${row##*|}
  rank() { case $1 in low) echo 1 ;; medium) echo 2 ;; high) echo 3 ;; xhigh) echo 4 ;; max) echo 5 ;; *) echo 0 ;; esac; }
  [ "$(rank "$effort")" -ge "$(rank "$want")" ] && exit 0
  key=$num-$effort
  msg="Effort check: session at $effort, below PLAN row $num's $want. If working on that row, tell the owner: /effort $want (Cmd+Shift+E in the app)."
else
  key=none-$effort
  msg="Effort check: session at $effort (measured, not a guess). If CLAUDE.md names another effort for this work, tell the owner: /effort <level>."
fi
marker="${TMPDIR:-/tmp}/effort-check-$session-$key"
[ -e "$marker" ] && exit 0
: > "$marker"
printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' "$msg"

#!/bin/sh
# Owner-wide hook (UserPromptSubmit), installed once in ~/.claude/settings.json. Tells a session
# which commits landed in its repo since the owner's last message, so it runs the sync skill
# instead of working from stale rules. The session's own commits are listed too; the note says to
# skip those. Silent when nothing new landed, outside a git repo and inside subagents (agent_id in
# the input). A missing session_id is a hook error, so a changed input format shows up.
dir=${CLAUDE_PROJECT_DIR:-.}
input=$(cat)
printf '%s' "$input" | jq -e 'has("agent_id")' >/dev/null 2>&1 && exit 0
session=$(printf '%s' "$input" | jq -r '.session_id // empty') || { echo 'sync-check: input is not JSON' >&2; exit 1; }
[ -n "$session" ] || { echo 'sync-check: no session_id in hook input' >&2; exit 1; }
head=$(GIT_OPTIONAL_LOCKS=0 git -C "$dir" rev-parse -q --verify HEAD 2>/dev/null) || exit 0
state="${TMPDIR:-/tmp}/sync-check-$session"
last=$(cat "$state" 2>/dev/null)
printf '%s\n' "$head" > "$state"
[ -n "$last" ] && [ "$last" != "$head" ] || exit 0
new=$(GIT_OPTIONAL_LOCKS=0 git -C "$dir" log --oneline --no-decorate -5 "$last..$head" 2>/dev/null)
count=$(GIT_OPTIONAL_LOCKS=0 git -C "$dir" rev-list --count "$last..$head" 2>/dev/null)
[ "${count:-0}" -gt 5 ] && new="$new
(+$((count - 5)) more)"
[ -n "$new" ] || new="(history was rewritten since ${last%"${last#???????}"}; compare with git log)"
printf 'Sync check: new commits since the owner'"'"'s last message (%s..%s):\n%s\nIf any aren'"'"'t yours, use the sync skill first.\n' \
  "${last%"${last#???????}"}" "${head%"${head#???????}"}" "$new"

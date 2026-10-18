# <Project>

<What this is in one or two sentences, and why its strict rules exist, if it has any.>
<What the owner knows; what to explain in this project (owner-wide preferences live in
`~/.claude/CLAUDE.md`).>

## Where things live
- What it is and owner decisions: `SPEC.md`. What's next: `PLAN.md`. Owner's guide: `HOW-TO-USE.md`.

## Commands
- Setup (fresh clone): `<command>`
- Run: `<command>`
- Check (must pass before a feature is done): `<command>`

## Invariants and traps
- <only project-specific, non-obvious rules>

## Who decides
Claude decides and reports engineering choices, and keeps going through steps that don't need the
owner (checks, fixes, re-runs). The owner decides scope, spending, the security and privacy model,
and anything irreversible or remote: for those, recommend and wait. Only the owner's reply
answers a question to them, never a prompt you scheduled yourself.

## Working rhythm
- "Next feature" = first unfinished row in PLAN's current stage. One feature per session.
- First check the app runs. Plan mode for multi-file work unless it fits in one sentence.
- Done = its "Done when" check passes on the tree you commit and you show that output. A new or
  reworded check counts once you've run every case it names and seen it fail on a known bad case;
  a new guard or hook must also pass this session's everyday commands. Never weaken a check or
  test without the owner's OK.
- Before calling it done: <run the finish-feature skill | fresh-context subagents on this model at
  high effort, not this session, run `/code-review high` and walk the row's Done when, this file's
  rules, the full diff, every existing test it changed or skipped (and why) and anything beyond the
  row, giving evidence or GAP for each><; screens are also tried in the running app><; High tier
  adds a security review in a second subagent on Opus>. Significant = a bug, GAP or missed
  requirement, with file, line and how it fails. Fix those, re-run Check and the Done when, then one
  fresh look at the fixes<, plus a security look on Opus for High tier>; anything significant goes
  to the owner, not another round.
- Then update PLAN status and affected docs in place, and commit: one commit per feature. End
  the session by naming the next row and the model · effort to set before starting it.
- Stage end (fresh session): <all checks, `/code-review high` on its commits, a PLAN result, sign-off
  | the owner runs `/stage-gate`>.
- Same mistake twice → propose one line here, or a hook if it can be enforced.

## Docs and git
- Edit docs in place; no dated journals; don't cite commit SHAs.
- Never amend, rebase or force-push anything already pushed. <No AI attribution.>

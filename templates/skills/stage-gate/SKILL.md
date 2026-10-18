---
name: stage-gate
description: Close the current stage of PLAN.md with full checks, a fresh-context review and the owner's sign-off.
disable-model-invocation: true
effort: high
---
Run this in a fresh session. The goal is an honest answer to "is this stage done?", not a green
summary.

1. Run every check and "Done when" in the current stage from a clean state; show real output,
   with the test count for each layer named in CLAUDE.md, so the shape is checked, not assumed.
2. Review all of the stage's commits in a fresh-context subagent at `high` effort on this
   session's model (never a smaller one; set the model explicitly): `/code-review high
   <first-commit>^..HEAD` (or the branch). If any feature was High tier, a second subagent at
   `high` effort, on Opus whatever this session's model, runs a security review of the same
   commits.
3. Reconcile docs: SPEC, PLAN and any risks agree with what was built; deferred items are listed
   as deferrals with the stage that owns them.
4. If the next stage puts the app in front of real users, walk PLAN's "Before real users" list
   with evidence or GAP for each line.
5. Ask the owner to do any checks only they can do (real device, real account), and record what
   they report as owner-reported.
6. Write a stage result of at most 10 lines under the stage in PLAN: what works, what's
   deferred, risks still open.
7. Ask the owner to sign off. Only then, in plan mode, draft the next stage's feature table.

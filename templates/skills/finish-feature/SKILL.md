---
name: finish-feature
description: Check that the current PLAN.md feature is really done, item by item, before reporting it done or committing it. Use every time a feature looks finished.
effort: high
---
Run this before telling the owner a feature is done. Your own sense of "done" is not evidence.

1. Run the row's "Done when" check and the Check command from `CLAUDE.md`; keep the real output.
2. Start a fresh-context subagent at `high` effort on this session's model (never a smaller one;
   set the model explicitly) to run `/code-review high` (always type the level) on the feature's
   diff and return the findings.< For High tier, start a second one at `high` effort on Opus,
   whatever this session's model, for a security review of the same diff.> The session that wrote
   the code doesn't review it.
3. Start a fresh-context subagent the same way as step 2's code review. Give it only this list and
   where to look, not your reasoning, and ask for evidence (file:line or command output) or GAP
   for each item:
   - the row's "Done when";
   - <for a feature with a screen: the behaviour, tried in the running app;>
   - every rule under "Working rhythm", "Invariants and traps" and "Docs and git" in `CLAUDE.md`;
   - <the sensitive-data rules, if the project has any>;
   - the docs this change should have updated (SPEC, PLAN, commands in `CLAUDE.md`);
   - the full diff, including any dependency change and whether its audit ran;
   - every existing test or check the change edited, skipped or deleted, each with its reason;
   - anything changed beyond what this row needed.
4. Significant means a bug, a GAP or a missed requirement or rule, each given with file, line, why
   it's wrong and how to show it fails, with realistic inputs (not the owner's real data) rather
   than only a test's own fixture values, and the impact stated no wider than that showed; cleanup
   suggestions are minor. Run that demonstration before fixing: one that doesn't fail here goes to
   the owner with its output, unfixed. A fix for a "never" or "every" rule that guards one of the
   owner's threats (global `CLAUDE.md`) first lists every path into it and closes them all, not only
   the one found; a tripwire for honest mistakes states its limit and stops. When the inputs can't
   all be listed, it allows known-good ones instead of refusing bad ones. Fix each significant item,
   or bring it to the owner as a proposed deferral, and fix the cheap minor items; then re-run step
   1 on the fixed tree and keep that output. When anything was fixed, have a fresh subagent, as in
   step 2's code review, review just the diff of those fixes< (for High tier, also a second one as
   in step 2's security review)>. Then stop: anything significant they find, or a fixed finding that
   comes back, goes to the owner rather than another round. List what's left for the owner.
5. Only then set the row's Status to done and commit. If anything changed after step 4's re-run,
   run step 1 again first: the output you show comes from the tree you commit, and a failure
   there is significant.

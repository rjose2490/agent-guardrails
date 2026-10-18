# <Project>: how to work on it

For you, the owner. Claude's rules are in `CLAUDE.md`; what's next is in `PLAN.md`. Start every
session in this folder (`<path>`). Effort: <medium for most rows; high for rows marked High>.
You check evidence first: the check output, the review findings, and then you try it. You read
the code when a check can't settle a question, and on High-tier rows (security, data, money,
anything hard to undo).

**Any working session.** Claude plans the first unfinished row in `PLAN.md` (you approve),
builds it, runs its "Done when" check, has it checked in a fresh context, shows you the evidence
and commits.
```text
next feature from the plan
```
**Same feature, another day.** Picks up where that session stopped.
```bash
claude --resume
```
**End of a stage, in a fresh session.** Every check re-run, a review of the whole stage, a short
result in `PLAN.md`, then your sign-off.
```text
<run the stage gate | /stage-gate>
```
**Claude seems stuck, or can't settle a hard call.** Claude normally does this itself: one step
more effort first, then it asks before using the Fable advisor (extra cost; not for security work).
```text
try higher effort, then ask me about the Fable advisor
```
**Something about the process helped or hurt.** One line in the bootstrap's lessons inbox.
```text
/project-bootstrap lesson <what happened>
```

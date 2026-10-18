# GUIDE-orchestrator-prompts.md — Orchestrator template reference

Reusable prompts for the key moments of the workflow. Copy, fill the
bracketed slots, paste. None of these files are read by any agent —
they're a reference for the human orchestrator.

---

## 1. Project kickoff (in Claude app / Opus 4.7)

Use when starting a brand new project from a fuzzy idea.

```
I want to build [brief idea, one or two sentences].

Constraints:
- Stack preferences: [or "open to suggestions"]
- Target scope: [X phases / can ship in a week / etc.]
- Hardware: [your machine]
- Executor: Gemma 4 26B A4B OptiQ via opencode (local, 32K context)
- Reviewer: Sonnet 4.6 via Claude Code

Before producing SPEC.md, interview me. Ask one question at a time.
Focus on scope, success criteria, edge cases, and any unstated
assumptions. When you have enough, produce a phased SPEC.md where each
phase ends with verifiable acceptance criteria. Phases should each
represent ~5-15 minutes of executor work and end with functionality I
can manually verify.
```

---

## 2. Feature addition to existing project (in Claude app / Opus 4.7)

Use when the project already has a SPEC.md, code, and you want to add
something new.

```
I want to add [feature description] to my existing project.

Current project: [name and one-line description]
Existing SPEC.md: [paste the relevant sections, or the full file if short]
Current state: [paste git log --oneline | head -10, or describe]

Before producing SPEC-<feature>.md, interview me about:
- How this feature relates to existing functionality
- Whether it modifies or replaces any current behavior
- What success looks like
- Edge cases and failure modes

Ask one question at a time. Produce a phased spec that integrates with
the current system rather than replacing it. Reference existing files
and routes where the new feature touches them.
```

---

## 3. Phase execution (in opencode CLI / Gemma 4 26B)

Use this as the first prompt of every new opencode session.

```
Execute Phase [N] from SPEC.md.
```

That's it. opencode's `instructions` config loads SPEC.md and AGENTS.md
automatically. The agent reads the phase, follows the protocol, and
ends with the `PHASE COMPLETE` block.

If the executor seems to drift mid-phase, this corrective prompt helps:

```
Pause. Re-read the acceptance criteria for the current phase in SPEC.md.
What in your work so far does not meet those criteria? Fix only what's
needed to meet them. Do not add scope.
```

---

## 4. Phase revision (in Claude app / Opus 4.7)

Use when a phase failed and needs the spec rewritten.

```
Phase [N] of [project name] failed.

Phase spec from SPEC.md:
[paste the phase section]

What the executor produced:
[paste relevant code, file paths, or short summary]

What went wrong:
[error messages, failed test output, or description]

Diagnose: was the spec under-specified, did the executor misread it,
or is there a deeper design issue? Then rewrite just this phase's
section of SPEC.md to be more explicit and avoid the failure mode.
Don't restructure the whole document — surgical edit only.
```

---

## 5. Review request (in Claude Code / Sonnet 4.6)

Use after each phase completes and you've verified acceptance criteria.

```
Review the changes from Phase [N] of this project.

Phase spec (from SPEC.md):
[paste the phase section, including acceptance criteria]

Diff to review:
[run: git diff HEAD~1 HEAD]
or just: review the most recent commit and its file changes

Please:
1. Run the test suite and report the result
2. Verify the acceptance criteria are fully met
3. Look for bugs, security issues, or fragile code
4. Check anything that violates AGENTS.md conventions
5. Note anything the spec didn't mention but should have

Report findings. Recommend either: no action, fixes to apply, or
scope changes for the next phase.
```

---

## 6. Stuck or confused executor (in opencode CLI)

Use mid-session when Gemma seems lost.

```
Stop. Summarize in 3 bullets:
- What the current phase says should exist when done
- What you've actually done so far
- What's blocking you or making you uncertain

Do not write any more code until I respond.
```

After reading the summary, decide: clarify and continue, or exit and
bring the issue back to the planner.

---

## 7. Mid-session context checkpoint (in opencode CLI)

Use when you sense the session is getting long but you don't want to
abandon it.

```
Pause. Estimate how full the context window is. If it's past 60%,
write a CHECKPOINT.md to the project root summarizing:
- Current phase and progress within it
- Files modified so far in this session
- Open decisions and what you'd do next

Then I'll exit and start fresh referencing CHECKPOINT.md.
```

---

## 8. Pre-flight reverse interview (in Claude app, before any project)

Use this when you have an idea but want to be challenged on it before
committing to a spec.

```
I'm considering building [idea]. Before I commit to a SPEC.md, push
back on it. Specifically:

- Is this scope realistic for the constraints listed in AGENTS.md?
- What's the smallest version that would prove the concept?
- What part of this is interesting vs. just busywork?
- What would make this fail or be abandoned?
- Is there a better-shaped project that achieves the same learning goals?

Be direct. I'd rather kill a bad idea now than discover the problem in
Phase 4.
```

---

## 9. End-of-feature retrospective (in Claude app)

Use after shipping a feature to capture lessons.

```
We just finished [feature name]. The SPEC.md, the actual commits, and
the review feedback from each phase are in the project.

Help me retrospect:
- Which phases went smoothly and which didn't?
- Where did the executor (Gemma) struggle?
- What should I add to AGENTS.md (project or global) so the next
  feature avoids those problems?
- Was the spec at the right level of detail, or did it need to be
  tighter / looser?

Produce a short retro doc I can save to docs/retros/<feature>.md and
specific suggested edits to AGENTS.md.
```

---

## Quick reference: which prompt for which moment

| Moment | Prompt | Tool |
|---|---|---|
| New project, fuzzy idea | 1 | Claude app (Opus) |
| Adding to existing project | 2 | Claude app (Opus) |
| Starting a phase | 3 | opencode (Gemma) |
| Phase failed, needs replan | 4 | Claude app (Opus) |
| Reviewing a finished phase | 5 | Claude Code (Sonnet) |
| Executor confused mid-phase | 6 | opencode (Gemma) |
| Context getting full mid-phase | 7 | opencode (Gemma) |
| Stress-testing an idea | 8 | Claude app (Opus) |
| After feature ships | 9 | Claude app (Opus or Sonnet) |

---

## Adding a feature to an existing workflow-managed project

Use this when a project has shipped (or is past Phase 1 at least) and
you want to add a new feature using the same agent workflow. The
project already has SPEC.md, AGENTS.md, opencode.json, and a git
history of phase commits.

Paste this into a new Claude Opus session along with the standard
bootstrap from `GUIDE-start-claude.md`.

```
I have a project that uses our multi-agent workflow. I want to add
a new feature.

Current SPEC.md is below. The latest committed phase is Phase <N>.
The feature I want to add is:

[Describe the feature in your own words. Don't over-specify — Opus
will reverse-interview you.]

What I need from you:
1. Reverse-interview me about scope, edge cases, and acceptance
   criteria for this feature
2. Decide whether the new work fits as additional phases appended
   to SPEC.md, or whether it needs its own SPEC-<feature>.md
3. If it integrates with existing phases (changes models, modifies
   endpoints), surface the integration points explicitly
4. Produce the new phase(s) following the same structure as the
   existing SPEC.md — when complete / acceptance verification /
   implementation specifics / out of scope

Do NOT propose tool changes. The stack is locked. If the feature
genuinely needs a new dependency, name it and explain why, but
default to using what's already in the project.

=== Current SPEC.md ===
[paste full SPEC.md here]
=== End SPEC.md ===

=== Current state ===
[paste relevant context: "We're past Phase 5 and have shipped X.
The README says Y. Recent commits: <git log --oneline -20>"]
=== End state ===
```

---

## Retrofitting an existing project to this workflow

Use this when you have a working project that was NOT built with this
workflow and you want to start using it — typically because you're
adding a feature and want the agent workflow's benefits going forward.

Paste this into a new Claude Opus session along with the bootstrap.

```
I have an existing project that wasn't built with our multi-agent
workflow. I want to adopt the workflow for new work on it.

Project description:
[What it does, what stack it uses, where it lives. Be specific about
the stack — Django/Flask/Rails/etc., database, frontend approach.
If you don't know the stack, say so and I'll figure out a way for
you to surface it.]

What I want to add:
[The new feature, in your own words.]

What I need from you, in this order:
1. First, archaeology: ask me targeted questions to reconstruct the
   project's current state. What models exist, what endpoints, what
   conventions, what tests, what's broken. One question at a time.
2. Produce a baseline SPEC.md that documents the CURRENT state of
   the project — what exists, not what should exist. This becomes
   the reference for future feature work.
3. Reverse-interview me about the new feature
4. Produce phase(s) for the new feature, layered on top of the baseline

Constraints:
- The baseline spec reflects reality, not aspirations. If the existing
  code is messy in ways the new feature doesn't need to inherit, that's
  a separate refactor decision — not bundled into feature work.
- Don't invent structure that isn't in the code
- Don't propose rewrites unless I explicitly ask
- If a baseline convention conflicts with global AGENTS.md, surface
  the conflict but don't impose the global default — the project's
  existing convention wins for that project unless I decide otherwise

I'll also need help setting up opencode.json and a project AGENTS.md
for this project if those don't exist yet. Address that after the
baseline spec is done.
```

---

## Resuming a project mid-phase after a break

Use this when you've stepped away from a project for days or weeks and
want to pick up where you left off. The state may be partial — some
sub-steps done, some not.

```
I'm resuming work on [project name]. I was last working on it
[time period ago].

Current SPEC.md:
[paste]

Current git state:
[paste output of: git log --oneline -10 and git status]

What I need from you:
1. Read the spec and git state, then tell me which phase appears
   to be active and how much of it looks done
2. If the working directory has uncommitted changes, tell me what
   they look like (you can ask me to paste git diff if needed)
3. Don't assume the orchestrator's previous decomposition is still
   valid — the project may have drifted from spec. Verify against
   reality.
4. Propose how to resume: continue where I left off, restart the
   current phase from scratch, or roll back uncommitted work first

Don't dispatch any work yet. Just diagnose and propose. I'll start
opencode and run the actual phase once we've agreed on the plan.
```

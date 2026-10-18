# Agent guardrails

These are the templates and hooks I use to run projects with AI coding agents, plus files from
my first AI workflow.

I built and maintain them with Claude Code. Claude Code wrote most of the file text. I decided
what the rules were and what each check had to catch, reviewed every draft, and tested that each
check refused the bad case and still let normal work through. When something went wrong in a
project, I logged it as a lesson and had it folded back into the templates.

## Why this exists

Agents said they had checked things they hadn't. A fix looked right but didn't work. Agents found
ways around rules, especially with tests. When they should have fixed the code or written the
right test, they wrote a test that passed without really checking anything. Sometimes a model accepted my
pushback when I was only checking its logic. Other times it said it had done something, and when
I pressed, it admitted it had done something less thorough. Each gap is small, but they add up,
and they can lead to dangerous outcomes.

I'm careful with my workspace and my work, and I want my results to be accurate. Building
guardrails like these takes time. Everyone having access to AI is a good
thing, and I wouldn't want to gatekeep what I've learned, so I'm sharing these.

## What I did about it

- **Learned what the tools could do.** Some problems I could prevent by how I asked. Others I
  could build in, with standing rules in `CLAUDE.md` or in skills for tasks I run often
- **Moved rules into automatic checks.** Settings and git hooks enforce the rules, so they don't
  depend on written instructions alone. Skipping commit checks or editing hook files needs my
  approval, and commits can't carry AI attribution. Each new check has to be seen refusing a real bad case and still
  passing everyday commands
- **Had fresh agents check claims.** Models kept saying tests passed, then another session or
  model would run them and find otherwise. So separate agents with no memory of the work review
  it and show how each serious finding fails, and the fixing session reproduces a finding before
  fixing it. When each review round kept finding a bad input nobody had listed, I switched from
  blocking known bad inputs to allowing only known-good ones
- **Had stronger models review weaker ones.** I gave different models the same coding tasks to
  see how each one worked through them, and had stronger models review the results
- **Re-checked my prompting habits on each new model.** I researched prompting best practices,
  and with each new model I checked whether what I'd learned still applied. Writing rules in all
  caps, for example, was something I dropped on newer models
- **Set effort from evidence.** I had AI compare Claude models and effort settings against
  published benchmarks, and tested how the effort settings behave. On that evidence, reviews and
  fix rounds run at high effort
- **Tested changes to the templates end to end.** Agents playing a project owner run a full
  setup, checked against judgment criteria and size limits on the process files
- **Kept parallel sessions on the same page.** Sessions working on one project get a notice when
  another session's changes land and have a routine for catching up. Handoffs to a fresh session
  are confirmed with a check that has a known correct answer. Lessons from each project are
  logged and folded back into the templates

## What's here

### `templates/`

The files a new project starts from. Text in `<angle brackets>` is a placeholder to fill in,
`<a | b>` means pick one, and a bracketed clause that continues a sentence is optional.

| File | What it does | Where it goes |
|---|---|---|
| `CLAUDE.md` | Claude's rules for the project: who decides what, what "done" means, and the review before each commit | project root |
| `HOW-TO-USE.md` | The owner's guide: what to say at each step and what to check | project root |
| `PLAN.md` | The feature-by-feature plan. Each row has a tier, a model and effort, and a "Done when" check | project root |
| `SPEC.md` | A short spec: what it is, decisions and open questions | project root |
| `settings.json` | Claude Code permissions that ask before a push, amend, rebase, hard reset, `git clean`, git config change, skipped hook or edit to the git hooks | `.claude/settings.json` |
| `agents/check-runner.md` | A small agent that runs the checks and reports without fixing anything | `.claude/agents/` |
| `skills/finish-feature/` | Checks a feature is really done, item by item, with fresh-context reviewers, before it's committed | `.claude/skills/` |
| `skills/stage-gate/` | Closes a stage of the plan: every check, a review of its commits, and the owner's sign-off | `.claude/skills/` |
| `githooks/commit-msg` | Rejects AI attribution in commit messages | `.githooks/` |
| `githooks/pre-commit` | Fast checks before every commit. Until its placeholders are filled in, it blocks every commit with a syntax error | `.githooks/` |
| `hooks/effort-check.sh` | Tells Claude the session's real effort setting, and says so when it's below what the plan's next row needs | `~/.claude/hooks/` |
| `hooks/sync-check.sh` | Tells a session which commits landed since the owner's last message | `~/.claude/hooks/` |

The git hooks run once a clone turns them on with `git config core.hooksPath .githooks`. They
aren't turned on in this repo. The two Claude Code hooks need `jq` and are registered in
`~/.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/effort-check.sh" }] }
    ],
    "UserPromptSubmit": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/sync-check.sh" }] }
    ]
  }
}
```

Some things the templates mention aren't included:
- The setup skill that interviews the owner and fills these templates in. `HOW-TO-USE.md` calls
  it the bootstrap, and its lesson command is part of it
- The sync skill that `sync-check.sh` points to
- My global `CLAUDE.md`, where the owner's threats that `finish-feature` refers to are listed
- The "Before real users" list that `stage-gate` reads, which the setup adds to a project's plan
  when it needs one

### `early-version/`

My first AI workflow, set up in OpenCode. An orchestrator agent handed spec-driven,
test-first work to build agents on a local model, and a frontier model (Claude) reviewed each
phase's changes before commit. `CLAUDE.md` and `AGENTS.md` files set each agent's role and rules.
The goal was for local models to do most of the work and the frontier model to review it, for
cost and efficiency.

On practice projects it worked: the local model wrote the code, the frontier model reviewed it
and gave feedback, the local model applied the feedback, and the change was committed. Some
hand-offs were copy-paste rather than automatic. I used it until newer, larger local models no
longer fit in my laptop's memory, then switched to frontier models (Claude Code, Codex).

| File | What it does |
|---|---|
| `reviewer-rules.md` | The reviewer's rules, installed as its global `CLAUDE.md` in Claude Code (the heading still shows an older file name). It runs the tests itself instead of trusting the orchestrator's claim, ends with a fixed verdict, and is the only role allowed to commit |
| `reviewer-settings.json` | The reviewer's Claude Code permissions |
| `opencode-with-reviewer.json` | The OpenCode setup: an orchestrator with its edit tools and `git commit` turned off (it still had a shell, so part of that rested on its prompt), a build agent, a reviewer that commits, and a read-only plan mode |
| `GUIDE-orchestrator-prompts.md` | The prompts I used at each step, from the kickoff interview to review and a stuck executor |
| `AGENTS-excerpt.md` | An excerpt of my global `AGENTS.md` at the time: communication, testing, git, workflow and agent architecture |

The orchestrator and build agents ran a local model set in a global config that isn't included.
`SPEC.md`, `GUIDE-start-claude.md` and that config are referenced but left out. Two small edits
from the originals: I removed two disabled entries for local servers from the OpenCode config and
replaced my hardware line in the prompts guide. The older model names are left as they were, and
parts of the prompts guide predate the final config.

## What I'd still like to figure out

- How to catch a model that doesn't follow its rules or misreports what it did, in ways that
  don't depend on each person building their own guardrails
- Whether there's a way to make AI follow its rules reliably and drift less
- How to keep a shared context, ruleset and way of working across many sessions. As I understand
  it, each session is shaped by the context it gets, and possibly by the order it gets it in
- Why the same prompt to the same model can lead to different behavior, not just different wording

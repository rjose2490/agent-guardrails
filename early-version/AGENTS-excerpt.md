## Communication

- No preamble. No "Great question!" No restating what I asked.
- Lead with the answer. Add context after, only if useful.
- Push back when I'm wrong. Agreement without analysis is worse than disagreement.
- One question at a time when blocked. Don't batch five clarifying questions.
- Admit uncertainty plainly: "I don't know" or "I'm guessing here" beats
  confident hallucination every time.
- Skip apologies. Acknowledge mistakes once, fix them, move on.

## Testing

Default methodology: test-driven development, modern interpretation.
Tests come before or alongside implementation, not after. The full
red-green-refactor cycle isn't dogma — what matters is the discipline
of letting the test define the behavior before code commits to it.

- For code with logic (parsing, validation, transformations, business
  rules, error handling, state machines): write the test first or
  alongside the implementation, in the same commit
- For trivial glue code (imports, framework boilerplate, simple wiring,
  one-line passthroughs): skip the test
- Heuristic: would a senior reviewer flag this as untested? Then test
  it. Would they roll their eyes at the test? Then skip it.
- Test behavior, not implementation. Tests that break on refactors
  are noise.
- A failing test should make the bug obvious without reading the test
- Integration tests for confidence, unit tests for speed. Prefer
  integration tests where they're not slow; reach for unit tests
  for tricky logic in isolation.
- E2E tests only where they earn their cost — typically critical user
  paths and integrations across system boundaries
- Don't write tests to hit coverage targets. Coverage is a side effect
  of testing the right things, not a goal.
- Mocks are a last resort. Real objects first, fakes second, mocks last.
- Run the tests after every meaningful change. Commit only when green.

## Git

- Commit messages: imperative mood, ≤72 char subject, body explains the *why*.
- Atomic commits. One logical change per commit. Squash WIP before merging.
- Never force push to shared branches. Never rewrite shared history.
- Don't commit secrets, .env files, lockfile-only changes mixed with code,
  or generated artifacts.
- Branch from main, name branches with a short kebab-case description
  (`fix-search-pagination`, not `bugfix-1234`).

## Workflow

- When a SPEC.md (or equivalent) exists, read it first. Execute one phase
  at a time. End with the agreed completion protocol.
- Verify before claiming done. Run the tests, the lints, the type checker.
  Report actual output, not expected output.
- When you encounter ambiguity the spec doesn't cover, stop. Ask. Don't
  improvise across files.
- If a phase fails twice the same way, escalate — don't grind.

## Agent architecture

Five-role workflow: planner (Opus in Claude app), orchestrator (local
Gemma, opencode primary agent), builder (local Gemma, opencode subagent
invoked via task tool), reviewer (Sonnet, either opencode subagent or
Claude Code), human. Each agent has its own system prompt describing
its role in detail.

SPEC.md, AGENTS.md, and config files are read-only for orchestrator
and builder — the edit tool is denied at the tool level. Commits
happen at phase boundaries only; the reviewer is the only role with
commit authority.

**Spec writing principle — every requirement must be verifiable.**
Every requirement in a phase's "when complete" section must have a
corresponding command in "acceptance verification." Prose alone gets
missed by the orchestrator. If you say a file must exist, add a test
that the file exists. If you say a config must contain X, add a grep
that verifies it.

**Known limitation — no build-to-orchestrator streaming.** The task
tool only returns the final sub-step summary. If a sub-step takes
significantly longer than expected (more than a few minutes with no
visible progress), interrupt manually and re-dispatch with corrective
context rather than waiting for a potentially bad result.

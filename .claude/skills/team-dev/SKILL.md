---
name: team-dev
description: >
  Team-based collaborative development using Agent Team orchestration.
  The current agent acts as Team Lead, coordinating haiku-engineer (developer),
  senior-engineer (code reviewer), and devops-engineer (ops reviewer) through
  plan → develop → review cycles. Use for ALL code change requests: new features,
  bug fixes, refactoring, infrastructure changes, or any task that modifies code.
  Triggers on: any code modification request, "팀으로 개발", "team develop",
  "implement this", "fix this bug", "add feature", "refactor", or general development tasks.
---

# Team Development Workflow

You are the **Team Lead**. Orchestrate the team using Agent Team tools.

## Team Roster

| Name | Model | subagent_type | Purpose |
|------|-------|---------------|---------|
| haiku-engineer | haiku | general-purpose | Develop code, create commits |
| senior-engineer | opus | general-purpose | Review: code quality, architecture, patterns |
| devops-engineer | opus | general-purpose | Review: reliability, security, ops, CI/CD |

## Setup

Create the team and task list before starting work:

```
TeamCreate: { team_name: "dev-team", agent_type: "team-lead" }
```

Then create tasks with `TaskCreate` for each unit of work (1 task = 1 commit).

## Cycle

```
Plan → Develop → Check → Review → (Approve or Fix) → Next cycle or Done
```

### Phase 1: Plan

Analyze the user's request and codebase. Break down into ordered, atomic tasks.
Create each task via `TaskCreate` with clear subject and description.
Set up dependencies between tasks via `TaskUpdate` if needed.

### Phase 2: Develop

Assign a task to haiku-engineer via `TaskUpdate(owner: "haiku-engineer")`.
Then spawn or message the engineer:

**First time (spawn):**
```
Task tool:
  subagent_type: general-purpose
  model: haiku
  mode: acceptEdits
  team_name: "dev-team"
  name: "haiku-engineer"
  prompt: |
    You are a Haiku Engineer. Check TaskList for your assigned tasks.
    Implement each task and commit. Mark tasks completed via TaskUpdate.
    Send results to team-lead via SendMessage when done.
    Follow existing code conventions. Do not modify files outside task scope.
```

**Subsequent tasks:** Use `SendMessage` to the idle haiku-engineer with new instructions.

Provide **complete context**: file paths, function signatures, related code snippets.

### Phase 3: Check & Request Review

After haiku-engineer reports completion, verify with `git log -1 --stat` and `git diff HEAD~1`.
Then spawn **both reviewers in parallel** (both Task calls in one message):

```
Task tool (Senior Engineer):
  subagent_type: general-purpose
  model: opus
  team_name: "dev-team"
  name: "senior-engineer"
  prompt: |
    You are a Senior Engineer. Check TaskList for review tasks assigned to you.
    Review the latest commit via `git diff HEAD~1`.
    Criteria: code quality, architecture, edge cases, naming, performance.
    Send verdict (APPROVE or REQUEST_CHANGES) with issues to team-lead via SendMessage.

Task tool (DevOps Engineer):
  subagent_type: general-purpose
  model: opus
  team_name: "dev-team"
  name: "devops-engineer"
  prompt: |
    You are a DevOps Engineer. Check TaskList for review tasks assigned to you.
    Review the latest commit via `git diff HEAD~1`.
    Criteria: security, reliability, deployment impact, CI/CD, resource usage.
    Send verdict (APPROVE or REQUEST_CHANGES) with issues to team-lead via SendMessage.
```

**Subsequent reviews:** Use `SendMessage` to idle reviewers with new review requests.

### Phase 4: Lead Decision

Wait for both reviewers to respond (messages arrive automatically).

- **Both APPROVE** → Mark review task completed. Proceed to next task or finish.
- **Any REQUEST_CHANGES** → Compile fix list. SendMessage to haiku-engineer with fix instructions. Only include issues you agree with; dismiss nitpicks.
- **Max 3 fix cycles per task.** If still not approved, accept with a note to user.

## Cleanup

When all tasks are done:
1. Send `shutdown_request` to all teammates
2. `TeamDelete` to clean up team resources
3. Present summary: tasks completed, files changed, commits made

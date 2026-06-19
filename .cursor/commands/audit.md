# Full repo review and BUILD_PLAN execution

Framework: use AGENT/HUMAN/LR/AUTO labels; Sequential before Parallel; gates after AGENT steps; update memory files at milestones.

**Stack:** `lightroom-rust` only.

## Step 1 — Review

Explore via targeted reads (active modules only — @docs/FOR_AGENTS.md token economy). Run:

```powershell
.\scripts\validate-bootstrap.ps1 -Quick
.\scripts\feature-gate.ps1 -Stack lightroom-rust -Ci
.\scripts\check-repo-hygiene.ps1
.\scripts\foss-audit.ps1
```

Check Dependabot/CodeQL via `gh` if authenticated. Write `CODE_REVIEW.md` from @CODE_REVIEW.md.example (severity: Critical / High / Medium / Low / Deferred). Do not commit `CODE_REVIEW.md`.

## Step 2 — BUILD_PLAN

Add a review sprint at the top of @BUILD_PLAN.md if findings need work. Link findings to CODE_REVIEW sections. Use ⬜ [AGENT] / ⬜ [HUMAN] format.

## Step 3 — Execute

Work Sequential [AGENT] items top-to-bottom. After each step:

```powershell
.\scripts\watch-agent-gates.ps1 -Once -Step scaffold
```

## Step 4 — Cleanup

Archive completed sprint to @COMPLETED_TASKS.md; slim active board; update Archived Sprints row.

Begin now.

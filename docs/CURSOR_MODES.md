# Cursor Modes

> Router for Cursor **Ask**, **Plan**, **Agent**, and **Debug** modes.

## Mode table

| Mode | When | Artifact | Do not use for |
|------|------|----------|----------------|
| **Ask** | Read-only exploration, algorithm questions | `KNOWLEDGE_BASE.md`, `docs/ALGORITHM.md` | Editing files |
| **Plan** | Non-trivial work: pipeline, CI, TM structural changes | BUILD_PLAN row + `### Critique` | Mechanical smoke fixes |
| **Agent** | Approved execution, `[AGENT]` BUILD_PLAN rows | `watch-agent-gates.ps1` | Unapproved architecture |
| **Debug** | Unknown root cause: smoke fail, 3-strike | KB + `docs/FOR_AGENTS.md` Failure Playbook | Template doc-only tasks |

BUILD_PLAN owner labels (`[AGENT]`/`[HUMAN]`/`[LR]`/`[AUTO]`) are orthogonal — see [BUILD_PLAN.md](../BUILD_PLAN.md).

## Trivial vs non-trivial

| Signal | Mode | Example |
|--------|------|---------|
| Read-only question | **Ask** | "How does Orchestrator.lua sequence phases?" |
| ≤3 files, no contract change, doc typo | **Agent** | TM.2 doc cross-link fix |
| New pipeline phase, CI workflow, root doc move | **Plan** | TM.4 security workflows |
| Same fix failed 3× or smoke red, unknown cause | **Debug** | "analyzer returned no output" on Windows |
| Mid-task architecture pivot | **Plan** | Moving plugin into `examples/` |

If uncertain, default to **Plan**.

## When to switch

| From | To | Trigger |
|------|-----|---------|
| Ask | Plan | User says "implement" or "build" |
| Plan | Agent | Plan approved |
| Agent | Debug | Gate fail after 3 attempts; LR smoke red |
| Agent | Plan | Schema change; production path move proposed |
| Debug | Agent | Root cause confirmed |

Do not debug in Plan Mode. Do not edit in Ask Mode.

## Prompt shortcuts

See [`PROMPT_LIBRARY.md`](../PROMPT_LIBRARY.md) — Entries 1 (session start), 4 (build verification), 10 (debug gate failure).

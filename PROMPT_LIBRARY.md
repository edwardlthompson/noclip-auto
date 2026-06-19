# Prompt Library — NoClip Auto

> Effective prompt strategies for this repository. Template-derived entries trimmed for **lightroom+rust** stack.

## Entry 1 — Session start (active sprint)

**Prompt:**

```
Read @docs/START_HERE.md and @BUILD_PLAN.md.
Find the current Sequential lane task. Respect [AGENT]/[HUMAN]/[LR] labels.
After each [AGENT] step run: .\scripts\watch-agent-gates.ps1 -Once -Step <tmN>
```

## Entry 2 — Reference mode (existing codebase)

**Prompt:**

```
Read @docs/FOR_AGENTS.md, @modules/lightroom/MODULE.md, and @modules/rust/MODULE.md.
Apply @.cursor/rules/*.mdc. Do not relocate NoClipAuto.lrdevplugin/ or noclip-analyze/.
```

## Entry 3 — Bootstrap / template migration

**Prompt:**

```
Read @docs/BOOTSTRAP_TEMPLATE_MAP.md and @BUILD_PLAN.md Sprint TM.
Preserve production paths. Run .\scripts\validate-bootstrap.ps1 -Quick after doc/scaffold changes.
Append major decisions to @DECISION_LOG.md.
```

## Entry 4 — Build verification (host)

**Prompt:**

```
Run host verification:
.\scripts\validate-bootstrap.ps1
.\scripts\smoke\m0_smoke.ps1
.\scripts\build-analyzer.ps1
.\scripts\smoke\m2_smoke.ps1
cd noclip-analyze; cargo test; cargo clippy -- -D warnings
Report pass/fail per step. Do not mark BUILD_PLAN complete until all pass.
```

## Entry 5 — Milestone gate (M0–M9)

**Prompt:**

```
Run .\scripts\run-milestone-gate.ps1 -Milestone N
On pass: .\scripts\archive-completed-tasks.ps1, update CHANGELOG.md and AGENT_MEMORY.md
```

## Entry 6 — Lightroom smoke (requires LR)

**Prompt:**

```
Run .\scripts\ensure-lr-running.ps1
.\scripts\install-plugin.ps1
.\scripts\smoke\m1_smoke.ps1
Label [LR] tasks — stop if H2 (LR not installed) without blocking non-LR work.
```

## Entry 7 — Pipeline / algorithm change

**Prompt:**

```
Read @docs/ALGORITHM.md and @docs/adr/0001-core-architecture.md before editing Core/Pipeline/.
Run .\scripts\verify-tone-quality.ps1 after phase logic changes.
Keep phase modules ≤200 lines.
```

## Entry 8 — Settings UI change

**Prompt:**

```
Read @docs/SETTINGS_UI.md and @.cursor/rules/settings-ui-hints.mdc.
Every Plugin Manager pref needs hint text. Use Core/SettingsUI.lua for slider rows.
```

## Entry 9 — Release preflight

**Prompt:**

```
.\scripts\build-analyzer.ps1 -Profile release-small
.\scripts\check-bundle-size.ps1
.\scripts\check-lua-size.ps1 -ShippedOnly
.\scripts\bench-analyzer.ps1
.\scripts\run-milestone-gate.ps1 -Milestone 6
Update CHANGELOG.md [Unreleased] section.
```

## Entry 10 — Debug gate failure

**Prompt:**

```
Gate failed. Read .cursor/agent-progress.json if present.
Check KNOWLEDGE_BASE.md for matching symptom.
Fix root cause — do not disable the gate.
Re-run: .\scripts\watch-agent-gates.ps1 -Once -Step <step>
After 3 failed attempts on the same step: halt and escalate to [HUMAN].
```

## Entry 11 — Slash commands

Type `/` in Agent chat. Registry: [docs/help/BATCH_COMMANDS.md](docs/help/BATCH_COMMANDS.md).

| Command | Use |
|---------|-----|
| `/verify` | Pre-PR: docs + gates + CI |
| `/gates` | Local validation only |
| `/build` | Plan → feature → gates |
| `/ship` | prerelease → push → regress |
| `/maintain` | triage → dependabot → audit |
| `/debug` | Defect with repro evidence |

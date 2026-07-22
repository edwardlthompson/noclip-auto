# Project Initialization Prompt — NoClip Auto

> Adapted from agent-project-bootstrap. This is a **live** Lightroom + Rust child repo, not a fresh template init.

You are operating on **NoClip Auto**: a FOSS Adobe Lightroom Classic plugin with a bundled Rust analyzer (`noclip-analyze`). License: **Apache-2.0**.

## Stack (locked)

- **Platform:** Lightroom Classic plugin (Lua `Lr*` SDK) + Rust analyzer
- **Production paths (do not relocate):** `NoClipAuto.lrdevplugin/`, `noclip-analyze/`
- **Primary OS for gates:** Windows 11 (PowerShell); macOS analyzer builds are CI-only / UNVALIDATED
- **Device label:** `[LR]` (maps to template `[ADB]` conceptually)

## Session protocol

1. Read `docs/START_HERE.md`
2. Pick Cursor mode via `docs/CURSOR_MODES.md`
3. Execute `BUILD_PLAN.md` **Sequential** `[AGENT]` rows first
4. Prefer local compute (`.cursor/rules/local-compute.mdc`) over Cloud Agents
5. Run gates after each step: `scripts/watch-agent-gates.ps1 -Once -Step <label>`

## Guardrails

- No network calls in plugin or analyzer v1
- UTF-8 without BOM for all text files (never UTF-16 on Windows)
- Conventional Commits going forward
- Do not adopt inactive stacks (web/python/android/design-tokens)
- Do not replace custom release (`publish-release.ps1`) with Release Please unless `[HUMAN]` approves
- Adobe Lightroom SDK is **not** in this repo

## Alignment reference

- Gap analysis: `docs/BOOTSTRAP_ALIGNMENT.md`
- Path map: `docs/BOOTSTRAP_TEMPLATE_MAP.md`
- Upstream: https://github.com/edwardlthompson/agent-project-bootstrap

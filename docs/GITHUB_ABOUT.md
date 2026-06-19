# GitHub repository metadata

Two-tier About policy (see [BUILD_PLAN.md](../BUILD_PLAN.md)):

| Tier | Where | Length | Contents |
|------|-------|--------|----------|
| **Short** | GitHub repo About (sidebar) | ~100 chars | One-line pitch; fits preview without truncation |
| **Long** | README `## About`, Plugin Manager | Unlimited | Version, release notes, changelog, GitHub, Venmo |

GitHub allows **350 characters** in the About field, but the repo sidebar **preview truncates around 80–120 characters**. Keep the live description under **120 chars**.

## About — short (live on GitHub)

```text
Auto-fix highlight and shadow clipping in Lightroom Classic. FOSS, local-only, Windows. Apache-2.0.
```

**Character count:** 97 / 350 (preview-safe)

Apply or update via:

```powershell
gh repo edit edwardlthompson/noclip-auto --description "Auto-fix highlight and shadow clipping in Lightroom Classic. FOSS, local-only, Windows. Apache-2.0."
```

**Do not** put the Venmo link in GitHub About — donation link lives in README and Plugin Manager only.

## About — long (README and Plugin Manager)

- [README.md](../README.md) — `## About` section
- [Core/About.lua](../NoClipAuto.lrdevplugin/Core/About.lua) + [PluginInfoProvider.lua](../NoClipAuto.lrdevplugin/PluginInfoProvider.lua)

## Topics

```
lightroom
lightroom-classic
lightroom-plugin
photography
photo-editing
open-source
rust
lua
windows
```

## Repository URL

```
https://github.com/edwardlthompson/noclip-auto
```

## Website (optional)

```
https://github.com/edwardlthompson/noclip-auto#readme
```

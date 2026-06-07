# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| 1.x     | Yes       |
| < 1.0   | No        |

## Reporting a vulnerability

Please report security issues privately via GitHub Security Advisories on this repository, or open a issue labeled `security` with minimal public detail and request private follow-up.

Do **not** disclose exploitable details in public issues before a fix is available.

## Scope

- `noclip-analyze` native binary (local JPEG analysis only — no network)
- Lightroom plugin Lua code (local catalog/develop operations)
- Install/update scripts

Out of scope: Adobe Lightroom Classic itself, third-party LR plugins.

## Safe defaults

- Analyzer runs locally with file paths passed from the plugin only.
- No network calls in v1.
- Temp preview JPEGs are deleted after analysis.

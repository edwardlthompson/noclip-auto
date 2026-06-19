# Privacy — NoClip Auto

> Local-only Lightroom plugin. No telemetry, no cloud, no accounts.

## Data we process (on device only)

| Data | Purpose | Stored where | Retention |
|------|---------|--------------|-----------|
| Preview JPEG (temp) | Clip counting via analyzer | LR temp / plugin export path | Deleted after analyze |
| Develop slider values | Tone recovery pipeline | Lightroom catalog | User-controlled |
| Plugin preferences | Threshold, tier, dry-run | `LrPrefs` (plugin scope) | Until user resets |
| Batch report JSON | Last-run summary | Plugin folder `NoClipAuto-last-run.json` | Overwritten each batch |

## Data we do not collect

- No analytics or tracking
- No network calls in plugin or analyzer (v1)
- No upload of photos, catalogs, or EXIF to any server
- No sale of personal data

## Update checks

NoClip Auto v1 does **not** phone home for updates. Users download releases manually from [GitHub Releases](https://github.com/edwardlthompson/noclip-auto/releases).

## Third parties

| Party | Role | Data shared |
|-------|------|-------------|
| Adobe | Host application (Lightroom Classic) | Per Adobe privacy policy |
| GitHub | Source/releases (optional, user-initiated) | Only what user uploads via git/gh |

Adobe Lightroom SDK is **not** bundled in this repository.

## User rights

Because processing is local:

- **Access / deletion:** Controlled via Lightroom catalog and plugin prefs
- **Portability:** Batch report JSON is user-readable; no cloud export

## DPIA note ([HUMAN])

EU personal data in photos may exist in the user's catalog. NoClip Auto does not extract identity metadata for transmission. Document processing as **local legitimate interest** (user-initiated edit) if a formal DPIA is required.

## Contact

Privacy inquiries: maintainers in `.github/CODEOWNERS` or [SECURITY.md](../SECURITY.md).

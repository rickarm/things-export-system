# things-export-system

Exports Things 3 task data to structured JSON every morning at 6 AM via macOS launchd. The JSON schema is designed for AI consumption — useful for task prioritization, pattern detection, and coaching insights with Claude or other LLMs.

## What Gets Exported

Each daily snapshot contains:
- **Open tasks** (excluding Someday/Archive) with scheduled date, due date, area, project, tags, and calculated fields (`is_in_today`, `is_overdue`, `days_until_due`)
- **Active projects** with task counts
- **Completed tasks** from the last 14 days

Files are saved to `~/Documents/ThingsSnapshot/YYYY-MM-DD_things_snapshot.json`.

## Key Files

| File | Purpose |
|---|---|
| `export_things_daily_snapshot.scpt` | AppleScript that queries Things 3 and writes the JSON file |
| `com.rickarmbrust.things-export.plist` | launchd plist — schedules the 6 AM daily export |
| `install.sh` | One-step installer: creates dirs, installs script, loads launchd job, runs a test |
| `uninstall.sh` | Removes launchd job and installed files |
| `update.sh` | Updates the installed AppleScript from source |
| `README.md` | Full documentation including JSON schema, AI prompts, customization |
| `QUICK_REFERENCE.md` | Command cheat sheet |
| `CHANGELOG.md` | Version history (v2.0 current) |
| `CONTRIBUTING.md` | Contribution guidelines |
| `LICENSE` | MIT license |

## Installation

```bash
chmod +x install.sh
./install.sh
```

## Manual Export

```bash
osascript ~/Scripts/export_things_daily_snapshot.scpt
```

## Installed File Locations

| Item | Location |
|---|---|
| AppleScript | `~/Scripts/export_things_daily_snapshot.scpt` |
| launchd plist | `~/Library/LaunchAgents/com.rickarmbrust.things-export.plist` |
| Daily exports | `~/Documents/ThingsSnapshot/YYYY-MM-DD_things_snapshot.json` |
| Logs | `~/Documents/ThingsSnapshot/export.log` / `export.error.log` |

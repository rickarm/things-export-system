# Things Daily Export System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-10.15%2B-blue.svg)](https://www.apple.com/macos/)
[![Things3](https://img.shields.io/badge/Things3-Required-green.svg)](https://culturedcode.com/things/)

A robust, privacy-aware system for exporting your Things data to JSON format for AI-driven analysis, prioritization, and cleanup.

> **Perfect for:** AI coaches, productivity enthusiasts, and anyone who wants to analyze their task patterns using LLMs like Claude, ChatGPT, or local models.

## Overview

This system automatically exports your Things data every morning at 6:00 AM to a structured JSON file. Each export includes:

1. **Open tasks** (excluding Someday/Archive)
2. **Active projects** with task counts
3. **Recent completions** (last 14 days) for pattern detection

The JSON schema is stable and designed for AI consumption, making it easy to:
- Prioritize tasks based on patterns
- Detect what gets done vs. what doesn't
- Identify cleanup opportunities
- Track project health

## Installation

### Quick Install

1. Download all files to a folder
2. Open Terminal and navigate to that folder
3. Run the installation script:

```bash
chmod +x install.sh
./install.sh
```

The script will:
- Create necessary directories
- Install the AppleScript to `~/Scripts/`
- Set up daily automated exports at 6:00 AM
- Run a test export to verify everything works

### Manual Installation

If you prefer to install manually:

1. **Create directories:**
```bash
mkdir -p ~/Scripts
mkdir -p ~/Documents/ThingsSnapshot
```

2. **Copy the AppleScript:**
```bash
cp export_things_daily_snapshot.scpt ~/Scripts/
chmod +x ~/Scripts/export_things_daily_snapshot.scpt
```

3. **Install the scheduler:**
```bash
cp com.rickarmbrust.things-export.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.rickarmbrust.things-export.plist
```

4. **Test the export:**
```bash
osascript ~/Scripts/export_things_daily_snapshot.scpt
```

## Usage

### Automated Daily Export

Once installed, exports run automatically every day at 6:00 AM. Files are saved to:
```
~/Documents/ThingsSnapshot/YYYY-MM-DD_things_snapshot.json
```

### Manual Export

Run an export anytime:
```bash
osascript ~/Scripts/export_things_daily_snapshot.scpt
```

### Viewing Exports

Open in any text editor or JSON viewer:
```bash
open ~/Documents/ThingsSnapshot/$(date +%Y-%m-%d)_things_snapshot.json
```

Or use `jq` for formatted viewing:
```bash
jq . ~/Documents/ThingsSnapshot/$(date +%Y-%m-%d)_things_snapshot.json
```

## JSON Schema

### Top-Level Structure

```json
{
  "generated_at": "2026-02-04T06:00:00Z",
  "date": "2026-02-04",
  "open_tasks": [...],
  "active_projects": [...],
  "completed_tasks_14d": [...]
}
```

### Open Task Object

```json
{
  "name": "Task name",
  "status": "open",
  "area": "Area name",
  "project": "Project name",
  "notes": "Task notes",
  "tags": ["tag1", "tag2"],
  "activation_date": "2026-02-01T09:00:00Z",
  "due_date": "2026-02-10T17:00:00Z",
  "creation_date": "2026-01-15T10:30:00Z",
  "modification_date": "2026-02-01T14:20:00Z"
}
```

### Active Project Object

```json
{
  "name": "Project name",
  "status": "open",
  "area": "Area name",
  "notes": "Project notes",
  "tags": ["tag1"],
  "due_date": "2026-03-01T17:00:00Z",
  "total_tasks": 15,
  "open_tasks": 8
}
```

### Completed Task Object

```json
{
  "name": "Task name",
  "area": "Area name",
  "project": "Project name",
  "tags": ["tag1"],
  "completion_date": "2026-02-03T14:30:00Z",
  "creation_date": "2026-01-20T09:00:00Z"
}
```

### Field Notes

- **Dates**: All dates are ISO 8601 format (`YYYY-MM-DDTHH:MM:SSZ`)
- **Null values**: Missing dates appear as `null` (not quoted)
- **Empty strings**: Missing area/project/notes appear as `""`
- **Tags**: Always an array, empty if no tags: `[]`

## AI Analysis Use Cases

This schema is optimized for AI-driven insights:

### 1. Prioritization
- **Due date clustering**: Identify tasks bunching up
- **Activation date patterns**: See what's been sitting "scheduled" too long
- **Project health**: Flag projects with high total_tasks but low progress

### 2. Pattern Detection
- **Completion velocity**: Track what types of tasks get done vs. neglected
- **Tag correlation**: Which tags correlate with completion?
- **Area balance**: Are you neglecting certain areas?

### 3. Cleanup Opportunities
- **Stale tasks**: Open tasks with old creation dates and no progress
- **Empty projects**: Projects with 0 open_tasks that should be archived
- **Overdue patterns**: Tasks consistently pushed past due dates

### 4. Coaching Insights
- **Identity alignment**: Do completed tasks match stated priorities?
- **Energy patterns**: When do you complete certain types of work?
- **Avoidance signals**: What stays "scheduled" indefinitely?

### Example AI Prompts

Here are some example prompts to use with your exported data:

**Prioritization:**
```
I've exported my Things tasks to JSON. Looking at my open_tasks, which 5 tasks
should I focus on today based on due dates, how long they've been pending, and
patterns in my completed tasks?
```

**Pattern Analysis:**
```
Analyze my completed_tasks_14d and tell me: What types of tasks do I complete
most often? Are there patterns in the tags or areas? What does this say about
my work style?
```

**Project Health:**
```
Review my active_projects. Which projects have been stagnant? Which ones have
many tasks but low completion rates? Suggest which I should archive or
re-energize.
```

**Cleanup:**
```
Look at tasks that were created more than 60 days ago but never completed.
Help me decide which to delete, defer, or recommit to.
```

## Logs and Debugging

### Log Files

Logs are saved to `~/Documents/ThingsSnapshot/`:
- `export.log` - Standard output from scheduled runs
- `export.error.log` - Error messages if something fails

### Check Scheduled Job Status

```bash
launchctl list | grep things-export
```

You should see: `com.rickarmbrust.things-export`

### View Recent Logs

```bash
tail -20 ~/Documents/ThingsSnapshot/export.log
tail -20 ~/Documents/ThingsSnapshot/export.error.log
```

### Manual Test Run

```bash
osascript ~/Scripts/export_things_daily_snapshot.scpt
```

## Troubleshooting

### "Operation not permitted" Error

**Problem**: macOS is blocking AppleScript access to Things.

**Solution**:
1. Open **System Preferences** → **Security & Privacy** → **Privacy**
2. Select **Automation** in the left sidebar
3. Find **Script Editor** or **osascript** and ensure **Things3** is checked

### No Export File Created

**Check these in order:**

1. **Verify Things is installed and running:**
```bash
open -a Things3
```

2. **Test the script manually:**
```bash
osascript ~/Scripts/export_things_daily_snapshot.scpt
```

3. **Check error logs:**
```bash
cat ~/Documents/ThingsSnapshot/export.error.log
```

### Scheduled Job Not Running

**Check if job is loaded:**
```bash
launchctl list | grep things-export
```

**Reload the job:**
```bash
launchctl unload ~/Library/LaunchAgents/com.rickarmbrust.things-export.plist
launchctl load ~/Library/LaunchAgents/com.rickarmbrust.things-export.plist
```

**Check system logs:**
```bash
log show --predicate 'subsystem == "com.apple.launchd"' --last 1h | grep things-export
```

### JSON Parsing Errors

The AppleScript includes robust escaping for:
- Quotes in task names
- Newlines in notes
- Special characters
- Unicode text

If you encounter parsing errors, check the error log and verify the JSON with:
```bash
jq . ~/Documents/ThingsSnapshot/$(date +%Y-%m-%d)_things_snapshot.json
```

## Customization

### Change Export Time

Edit the plist file:
```bash
nano ~/Library/LaunchAgents/com.rickarmbrust.things-export.plist
```

Change the `Hour` and `Minute` values:
```xml
<key>StartCalendarInterval</key>
<dict>
	<key>Hour</key>
	<integer>8</integer>  <!-- Change this -->
	<key>Minute</key>
	<integer>30</integer>  <!-- Change this -->
</dict>
```

Reload:
```bash
launchctl unload ~/Library/LaunchAgents/com.rickarmbrust.things-export.plist
launchctl load ~/Library/LaunchAgents/com.rickarmbrust.things-export.plist
```

### Change Completion Window

Edit the AppleScript to change the 14-day lookback:
```applescript
set fourteenDaysAgo to (current date) - (14 * days)  -- Change 14 to your preference
```

### Exclude Notes (Privacy)

To exclude task notes from exports, change this line in the AppleScript:
```applescript
"\"notes\": \"" & my escapeJSON(taskNotes) & "\", " & ¬
```

To:
```applescript
"\"notes\": \"\", " & ¬
```

### Change Output Directory

Edit both the AppleScript and plist file to use a different location.

**In the AppleScript:**
```applescript
set outputDir to POSIX path of (path to home folder) & "Documents/ThingsSnapshot/"
```

**In the plist:**
```xml
<key>StandardOutPath</key>
<string>/Users/rick/Documents/ThingsSnapshot/export.log</string>
```

## Uninstall

To completely remove the system:

```bash
# Unload the scheduled job
launchctl unload ~/Library/LaunchAgents/com.rickarmbrust.things-export.plist

# Remove files
rm ~/Library/LaunchAgents/com.rickarmbrust.things-export.plist
rm ~/Scripts/export_things_daily_snapshot.scpt

# Optionally remove export directory
# rm -rf ~/Documents/ThingsSnapshot
```

## Privacy & Security

- **Local only**: All data stays on your Mac
- **No network access**: The script never transmits data
- **Readable format**: JSON is human-readable and auditable
- **Notes optional**: You can disable notes export if needed
- **Sandboxed**: launchd runs with your user permissions only

## File Locations Reference

| Item | Location |
|------|----------|
| AppleScript | `~/Scripts/export_things_daily_snapshot.scpt` |
| launchd plist | `~/Library/LaunchAgents/com.rickarmbrust.things-export.plist` |
| Daily exports | `~/Documents/ThingsSnapshot/YYYY-MM-DD_things_snapshot.json` |
| Standard log | `~/Documents/ThingsSnapshot/export.log` |
| Error log | `~/Documents/ThingsSnapshot/export.error.log` |

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Support & Feedback

- 🐛 **Found a bug?** Open an [issue](https://github.com/rickarm/things-export-system/issues)
- 💡 **Feature idea?** Open a [feature request](https://github.com/rickarm/things-export-system/issues)
- ❓ **Questions?** Check the troubleshooting section or open a [question issue](https://github.com/rickarm/things-export-system/issues)

## Roadmap

Planned features for future releases:

- [ ] Configurable completion lookback window
- [ ] Multiple export format options (CSV, simplified JSON)
- [ ] Export statistics summary
- [ ] Automatic cleanup of old exports
- [ ] Web dashboard for visualizing patterns
- [ ] Integration with popular AI tools

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built for the [Things3](https://culturedcode.com/things/) task manager
- Inspired by the need for AI-driven productivity insights
- Thanks to all contributors and users!

## Version

Version 1.0 - February 2026

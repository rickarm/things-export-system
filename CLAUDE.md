# Things Export System: Daily Task Snapshot

AppleScript that exports Things 3 tasks and projects to JSON daily. Used by sherlock-hq dashboard and AI analysis.

## Development Workflow

See `KB-Development-Workflow.md` in the Knowledge Base for the full workflow. Summary:

1. Bugs and features are tracked as **GitHub Issues**
2. Claude works on a **feature branch** (worktrees for isolation in local sessions)
3. Claude pushes the branch and opens a **Pull Request**
4. Rick reviews and merges the PR
5. Adding the `claude` label to an issue triggers Claude via GitHub Actions

## Commands

```bash
# Manual export
osascript ~/Scripts/export_things_daily_snapshot.scpt

# Install (creates dirs, copies files, loads plist)
./install.sh
```

## Architecture

```
export_things_daily_snapshot.scpt    # Main AppleScript (installed to ~/Scripts/)
com.rickarmbrust.things-export.plist # launchd config (runs daily at 6 AM)
install.sh                           # Installer script
```

## Output

- File: `~/kb/ThingsSnapshot/YYYY-MM-DD_things_snapshot.json`
- Logs: `~/kb/ThingsSnapshot/export.log` and `export.error.log`
- Schema version: 2.0

### JSON structure (v2.0)
- `open_tasks` — name, status, area, project, notes, tags, scheduled_date, due_date, is_in_today, is_overdue
- `active_projects` — name, status, area, notes, tags, due_date, total_tasks, open_tasks
- `completed_tasks_14d` — tasks completed in the last 14 days

## Gotchas

- Requires macOS Automation permissions (Privacy & Security → Automation → Things3)
- Plist has `USERNAME` placeholder — `install.sh` replaces it
- `scheduled_date` = when you plan to START; `due_date` = deadline
- Completion lookback hardcoded to 14 days
- The script is installed to `~/Scripts/`, not run from the repo directly

# Things Export - Quick Reference

## Common Commands

### Run Export Manually
```bash
osascript ~/Scripts/export_things_daily_snapshot.scpt
```

### View Today's Export
```bash
open ~/kb/ThingsSnapshot/$(date +%Y-%m-%d)_things_snapshot.json
```

### View Today's Export (formatted)
```bash
jq . ~/kb/ThingsSnapshot/$(date +%Y-%m-%d)_things_snapshot.json
```

### Check Scheduled Job Status
```bash
launchctl list | grep things-export
```

### View Recent Export Logs
```bash
tail -20 ~/kb/ThingsSnapshot/export.log
```

### View Recent Errors
```bash
tail -20 ~/kb/ThingsSnapshot/export.error.log
```

### Reload Scheduled Job
```bash
launchctl unload ~/Library/LaunchAgents/com.rickarmbrust.things-export.plist
launchctl load ~/Library/LaunchAgents/com.rickarmbrust.things-export.plist
```

## File Locations

- **Script**: `~/Scripts/export_things_daily_snapshot.scpt`
- **Scheduler**: `~/Library/LaunchAgents/com.rickarmbrust.things-export.plist`
- **Exports**: `~/kb/ThingsSnapshot/YYYY-MM-DD_things_snapshot.json`
- **Logs**: `~/kb/ThingsSnapshot/export.log`

## Troubleshooting

### Grant Automation Permission
System Preferences → Security & Privacy → Privacy → Automation
→ Enable "Script Editor" or "osascript" access to "Things3"

### Test Script Manually
```bash
osascript ~/Scripts/export_things_daily_snapshot.scpt
```

### Check System Logs
```bash
log show --predicate 'subsystem == "com.apple.launchd"' --last 1h | grep things-export
```

## AI Analysis Examples

### Count Open Tasks
```bash
jq '.open_tasks | length' ~/kb/ThingsSnapshot/$(date +%Y-%m-%d)_things_snapshot.json
```

### List Overdue Tasks
```bash
jq '.open_tasks[] | select(.due_date != null and .due_date < now) | .name' ~/kb/ThingsSnapshot/$(date +%Y-%m-%d)_things_snapshot.json
```

### Tasks by Area
```bash
jq -r '.open_tasks | group_by(.area) | .[] | "\(.[0].area): \(length) tasks"' ~/kb/ThingsSnapshot/$(date +%Y-%m-%d)_things_snapshot.json
```

### Completed Tasks Count (14d)
```bash
jq '.completed_tasks_14d | length' ~/kb/ThingsSnapshot/$(date +%Y-%m-%d)_things_snapshot.json
```

### Projects Health
```bash
jq -r '.active_projects[] | "\(.name): \(.open_tasks)/\(.total_tasks) open"' ~/kb/ThingsSnapshot/$(date +%Y-%m-%d)_things_snapshot.json
```

## Schedule

Exports run daily at **6:00 AM**

To change: Edit `~/Library/LaunchAgents/com.rickarmbrust.things-export.plist`

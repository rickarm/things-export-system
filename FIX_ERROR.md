# Fix for AppleScript Errors

## The Problems

You may have encountered one or both of these errors:

**Error 1:**
```
Things3 got an error: Can't make area into type specifier. (-1700)
```
Caused by AppleScript operator precedence issue.

**Error 2:**
```
The variable scheduled is not defined. (-2753)
```
Caused by using invalid status constant. Things only supports: `open`, `completed`, `canceled`.

## The Solution

I've fixed the AppleScript. To update your installation:

### Quick Fix (Recommended)

```bash
cd path/to/things-export-system
./update.sh
```

This will:
1. Back up your current script automatically
2. Install the fixed version
3. Test the export to confirm it works

### Manual Fix (Alternative)

If you prefer to update manually:

```bash
# Back up the old version
cp ~/Scripts/export_things_daily_snapshot.scpt ~/Scripts/export_things_daily_snapshot.scpt.backup

# Copy the fixed version
cp export_things_daily_snapshot.scpt ~/Scripts/

# Test it
osascript ~/Scripts/export_things_daily_snapshot.scpt
```

## What Was Fixed

**Original (broken):**
```applescript
to dos whose status is not canceled and status is not completed and area is not missing value or project is not missing value
```

**First attempt (also broken):**
```applescript
to dos whose status is open or status is scheduled
```
Problem: "scheduled" isn't a valid status in Things' API

**Final (working):**
```applescript
to dos whose status is not completed and status is not canceled
```

This works because Things only has three status values: `open`, `completed`, and `canceled`.

## Verification

After updating, you should see:
```
Export complete: /Users/richardarmbrust/Documents/ThingsSnapshot/2026-02-04_things_snapshot.json
```

Check the file:
```bash
open ~/Documents/ThingsSnapshot/$(date +%Y-%m-%d)_things_snapshot.json
```

Or verify with jq:
```bash
jq . ~/Documents/ThingsSnapshot/$(date +%Y-%m-%d)_things_snapshot.json | head -20
```

## Still Having Issues?

Check the error log:
```bash
cat ~/Documents/ThingsSnapshot/export.error.log
```

Verify Things automation permissions:
- System Preferences → Security & Privacy → Privacy → Automation
- Ensure "Script Editor" or "osascript" can control "Things3"

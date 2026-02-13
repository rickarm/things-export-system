# Changelog

## Version 2.0 - February 13, 2026

### 🎉 Major Schema Update

This release significantly improves the export schema to align with Things' date model and add AI-friendly metadata.

### Breaking Changes

**Field Renamed:**
- `activation_date` → `scheduled_date`
  - Better reflects Things terminology ("When" = when to START)
  - Clearer distinction from `due_date` (when to FINISH)
  - See [MIGRATION_V2.md](MIGRATION_V2.md) for upgrade guide

### New Features

**Schema Version Tracking:**
- Added `schema_version: "2.0"` to top-level JSON
- Enables tools to detect and handle schema changes

**Inline Field Guide:**
- Added `field_guide` object explaining date fields
- Helps AI understand Things' date model without external documentation

**AI-Friendly Calculated Fields:**
Each task now includes:
- `is_in_today` (boolean) - Is scheduled date today or earlier?
- `is_overdue` (boolean) - Is past the deadline?
- `days_until_due` (integer/null) - Days remaining until deadline
- `days_since_scheduled` (integer/null) - Days since task became active

These fields eliminate the need for AI to do complex date math.

### Improvements

**Better Error Handling:**
- AppleScript now auto-launches Things3 if not running
- Improved file I/O error handling with specific error messages
- Better error propagation for debugging

**Installation Pre-Flight Checks:**
- Verifies Things3 is installed before running
- Checks for osascript availability
- Checks for launchctl availability
- Provides helpful error messages for missing dependencies

**Documentation:**
- Added explanation of Things date model (scheduled vs due)
- Updated schema examples with new fields
- Added migration guide for v1.0 users
- Added example AI prompts leveraging new fields

### Migration

See [MIGRATION_V2.md](MIGRATION_V2.md) for detailed upgrade instructions.

**Quick Upgrade:**
```bash
git pull
./install.sh
```

### Why v2.0?

Based on user feedback, the `activation_date` field name was confusing:
- It's actually Things' "scheduled date" (when to start)
- Many users confused it with "due date" (when to finish)
- AI agents often misunderstood the Today list behavior

v2.0 fixes this with clear naming and helpful calculated fields.

---

## Version 1.2 - February 4, 2026

### Fixed
- **Invalid status constant**: Fixed "The variable scheduled is not defined (-2753)" error
  - Changed queries from `status is open or status is scheduled` to `status is not completed and status is not canceled`
  - Things' AppleScript API only supports: `open`, `completed`, and `canceled` as status values
  - "scheduled" is not a valid status constant in Things3

## Version 1.1 - February 4, 2026

### Fixed
- **AppleScript query error**: Fixed "Can't make area into type specifier (-1700)" error
  - Changed task query from complex `and`/`or` logic to simpler status checks
  - This fixes operator precedence issues with `and`/`or` in AppleScript

- **Improved error handling**: Added helper functions for safe area/project name extraction
  - `getAreaName()` - Safely extracts area name with proper null checking
  - `getProjectName()` - Safely extracts project name with proper null checking
  - Reduces try/catch blocks and makes code more maintainable

### Technical Details

The original query had an operator precedence problem:
```applescript
# Old (broken)
to dos whose status is not canceled and status is not completed and area is not missing value or project is not missing value
```

This was being parsed as:
```
(status is not canceled) AND (status is not completed) AND (area is not missing value) OR (project is not missing value)
```

The `OR` at the end caused Things to fail when evaluating `area is not missing value`.

The fix uses Things' built-in status values:
```applescript
# New (working)
to dos whose status is open or status is scheduled
```

This naturally excludes:
- Completed tasks (`status is completed`)
- Canceled tasks (`status is canceled`)
- Someday tasks (which have their own status)

### How to Update

If you've already installed the system and encountered the error:

1. Navigate to the directory containing these files
2. Run the update script:
   ```bash
   ./update.sh
   ```

This will:
- Back up your current script
- Install the fixed version
- Run a test export to verify it works

### Notes

- The fixed version produces identical JSON output
- No changes to the launchd scheduler or directory structure
- Your existing exports are not affected
- The backup of your old script is saved with a timestamp

---

## Version 1.0 - February 4, 2026

### Initial Release
- AppleScript to export Things data to JSON
- Daily automated exports via launchd
- Schema includes open tasks, active projects, and 14-day completions
- Installation and uninstall scripts
- Comprehensive documentation

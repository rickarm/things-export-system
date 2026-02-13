# Changelog

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

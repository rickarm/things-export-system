# Migration Guide: v1.0 → v2.0

## What Changed in v2.0

Version 2.0 improves the export schema to better align with Things' date model and add AI-friendly metadata.

### Schema Changes

#### 1. Renamed Fields (Breaking Change)

| v1.0 Field | v2.0 Field | Meaning |
|------------|------------|---------|
| `activation_date` | `scheduled_date` | When to **START** the task (Things "When" field) |
| `due_date` | `due_date` | When to **FINISH** the task (unchanged) |

**Why?** The term "activation_date" was confusing. Things uses "scheduled" to mean "when to start," which is clearer for both humans and AI.

#### 2. New Top-Level Fields

```json
{
  "schema_version": "2.0",  // NEW: Version tracking
  "field_guide": { ... },    // NEW: AI-friendly field descriptions
  ...
}
```

#### 3. New Task-Level Fields

Each task in `open_tasks` now includes:

```json
{
  "is_in_today": true,           // NEW: Is scheduled date today or earlier?
  "is_overdue": false,            // NEW: Is past the deadline?
  "days_until_due": 7,            // NEW: Days remaining (negative if overdue)
  "days_since_scheduled": 12      // NEW: Days since task became active
}
```

These fields help AI analyze tasks without complex date math.

## Migration Strategies

### Option 1: Fresh Start (Recommended)

Simply update to v2.0 and start fresh. Your new exports will use the improved schema.

**Steps:**
1. Pull latest changes: `git pull`
2. Run the installer: `./install.sh`
3. Test: `osascript ~/Scripts/export_things_daily_snapshot.scpt`
4. Verify: `jq '.schema_version' ~/Library/Mobile\ Documents/com~apple~CloudDocs/kb/ThingsSnapshot/$(date +%Y-%m-%d)_things_snapshot.json`

### Option 2: Keep Old Exports + Convert

If you have AI workflows relying on v1.0 exports, you can convert them.

**Conversion Script (jq):**

```bash
#!/bin/bash
# convert_v1_to_v2.sh - Convert v1.0 exports to v2.0 schema

input_file="$1"
output_file="${input_file%.json}_v2.json"

jq '
  # Add schema version
  .schema_version = "2.0" |

  # Add field guide
  .field_guide = {
    "scheduled_date": "Start date - when you plan to BEGIN this task",
    "due_date": "Deadline - when this task must be COMPLETED",
    "is_in_today": "Boolean - is this task scheduled for today or earlier?",
    "is_overdue": "Boolean - is this task past its deadline?",
    "days_until_due": "Integer - days remaining until deadline",
    "days_since_scheduled": "Integer - days since task became active"
  } |

  # Rename activation_date to scheduled_date in all tasks
  .open_tasks |= map(
    .scheduled_date = .activation_date |
    del(.activation_date) |

    # Add placeholder metadata (cannot calculate from static export)
    .is_in_today = null |
    .is_overdue = null |
    .days_until_due = null |
    .days_since_scheduled = null
  )
' "$input_file" > "$output_file"

echo "Converted: $output_file"
```

**Usage:**
```bash
chmod +x convert_v1_to_v2.sh
./convert_v1_to_v2.sh 2026-02-12_things_snapshot.json
```

**Note:** Converted files will have `null` for calculated fields since we can't retroactively compute them.

### Option 3: Support Both Versions

If you're building tools that consume exports, detect the version:

```javascript
// JavaScript example
function parseThingsExport(data) {
  const version = data.schema_version || "1.0";

  if (version === "1.0") {
    // Map old field names
    data.open_tasks = data.open_tasks.map(task => ({
      ...task,
      scheduled_date: task.activation_date,
      // Add default values for new fields
      is_in_today: null,
      is_overdue: null,
      days_until_due: null,
      days_since_scheduled: null
    }));
  }

  return data;
}
```

```python
# Python example
def parse_things_export(data):
    version = data.get("schema_version", "1.0")

    if version == "1.0":
        # Map old field names
        for task in data.get("open_tasks", []):
            task["scheduled_date"] = task.pop("activation_date", None)
            # Add default values
            task["is_in_today"] = None
            task["is_overdue"] = None
            task["days_until_due"] = None
            task["days_since_scheduled"] = None

    return data
```

## AI Prompt Updates

If you have saved AI prompts that reference fields, update them:

### Before (v1.0)
```
Look at tasks where activation_date is more than 30 days ago
```

### After (v2.0)
```
Look at tasks where days_since_scheduled > 30
```

Or even better:
```
Look at tasks where is_in_today is true but days_since_scheduled > 30
```

## FAQ

### Q: Will my old exports still work?

**A:** Yes! Old v1.0 exports are valid JSON and won't break. However, they lack the new helpful fields and use the confusing `activation_date` name.

### Q: Can I run v1.0 and v2.0 side-by-side?

**A:** No. The installer replaces the AppleScript. If you need both, keep a backup of the v1.0 script.

### Q: What if my AI tool breaks?

**A:** If you have custom tools that expect `activation_date`, use Option 3 above to add compatibility shims.

### Q: When will v1.0 be deprecated?

**A:** v1.0 is deprecated as of February 2026. New installations should use v2.0. We won't maintain v1.0.

## Getting Help

- **Issues:** https://github.com/rickarm/things-export-system/issues
- **Discussions:** https://github.com/rickarm/things-export-system/discussions

## Summary

**Bottom line:** Just update to v2.0! The new schema is clearer and more powerful for AI analysis. Unless you have critical automation depending on v1.0, there's no reason to stay on the old version.

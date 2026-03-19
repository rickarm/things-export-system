#!/bin/bash
# Update script for Things Daily Export System
# This updates just the AppleScript file with the fixed version

set -e

echo "========================================="
echo "Things Daily Export - Update"
echo "========================================="
echo ""

SCRIPT_FILE="$HOME/Scripts/export_things_daily_snapshot.scpt"
CURRENT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Load local config if present
if [ -f "$CURRENT_DIR/.local-config.sh" ]; then
	source "$CURRENT_DIR/.local-config.sh"
fi
SNAPSHOT_BASE="${THINGS_SNAPSHOT_DIR:-$HOME/Documents/ThingsSnapshot}"

if [ ! -f "$SCRIPT_FILE" ]; then
	echo "❌ Error: AppleScript not found at $SCRIPT_FILE"
	echo "Please run install.sh first."
	exit 1
fi

echo "Backing up current script..."
cp "$SCRIPT_FILE" "$SCRIPT_FILE.backup.$(date +%Y%m%d_%H%M%S)"
echo "✓ Backup created"
echo ""

echo "Installing updated AppleScript..."
cp "$CURRENT_DIR/export_things_daily_snapshot.scpt" "$SCRIPT_FILE"
chmod +x "$SCRIPT_FILE"
echo "✓ Script updated"
echo ""

echo "Testing updated export..."
osascript "$SCRIPT_FILE"
echo ""

TODAY=$(date +%Y-%m-%d)
EXPORT_FILE=$(ls -t "$SNAPSHOT_BASE/${TODAY}"_*_things_snapshot.json 2>/dev/null | head -1)

if [ -n "$EXPORT_FILE" ] && [ -f "$EXPORT_FILE" ]; then
	FILE_SIZE=$(wc -c < "$EXPORT_FILE" | tr -d ' ')
	echo "========================================="
	echo "Update successful!"
	echo "========================================="
	echo ""
	echo "Export file created: $EXPORT_FILE"
	echo "File size: $FILE_SIZE bytes"
	echo ""
else
	echo "⚠️  Warning: Export file was not created."
	echo "Check the error log: $SNAPSHOT_BASE/export.error.log"
	exit 1
fi

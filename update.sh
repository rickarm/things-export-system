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
EXPORT_FILE="$HOME/Library/Mobile Documents/com~apple~CloudDocs/My Knowledge Base System/ThingsSnapshot/${TODAY}_things_snapshot.json"

if [ -f "$EXPORT_FILE" ]; then
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
	echo "Check the error log: $HOME/Library/Mobile Documents/com~apple~CloudDocs/My Knowledge Base System/ThingsSnapshot/export.error.log"
	exit 1
fi

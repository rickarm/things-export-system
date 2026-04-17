#!/bin/bash
# Uninstall script for Things Daily Export System

set -e

echo "========================================="
echo "Things Daily Export - Uninstall"
echo "========================================="
echo ""

LAUNCHD_PLIST="$HOME/Library/LaunchAgents/com.rickarmbrust.things-export.plist"
SCRIPT_FILE="$HOME/Scripts/export_things_daily_snapshot.scpt"

# Load local config if present
CURRENT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$CURRENT_DIR/.local-config.sh" ]; then
	source "$CURRENT_DIR/.local-config.sh"
fi
SNAPSHOT_DIR="${THINGS_SNAPSHOT_DIR:-$HOME/kb/ThingsSnapshot}"

# Unload launchd job
if [ -f "$LAUNCHD_PLIST" ]; then
	echo "Unloading scheduled job..."
	launchctl unload "$LAUNCHD_PLIST" 2>/dev/null || true
	echo "✓ Scheduled job unloaded"
else
	echo "⚠️  Scheduled job not found (may already be uninstalled)"
fi
echo ""

# Remove launchd plist
if [ -f "$LAUNCHD_PLIST" ]; then
	echo "Removing scheduler configuration..."
	rm "$LAUNCHD_PLIST"
	echo "✓ Scheduler removed"
else
	echo "⚠️  Scheduler configuration not found"
fi
echo ""

# Remove AppleScript
if [ -f "$SCRIPT_FILE" ]; then
	echo "Removing AppleScript..."
	rm "$SCRIPT_FILE"
	echo "✓ AppleScript removed"
else
	echo "⚠️  AppleScript not found"
fi
echo ""

# Ask about export directory
if [ -d "$SNAPSHOT_DIR" ]; then
	echo "Export directory still exists: $SNAPSHOT_DIR"
	echo ""
	read -p "Do you want to delete all exported snapshots? (y/N) " -n 1 -r
	echo ""
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		rm -rf "$SNAPSHOT_DIR"
		echo "✓ Export directory deleted"
	else
		echo "⊙ Export directory preserved"
	fi
else
	echo "⊙ Export directory not found (may already be deleted)"
fi
echo ""

echo "========================================="
echo "Uninstall complete!"
echo "========================================="

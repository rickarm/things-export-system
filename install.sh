#!/bin/bash
# Installation script for Things Daily Export System
# This script sets up the AppleScript and launchd scheduler

set -e  # Exit on any error

echo "========================================="
echo "Things Daily Export - Installation"
echo "========================================="
echo ""

# Pre-flight checks
echo "Running pre-flight checks..."

# Check if Things3 is installed
if [ ! -d "/Applications/Things3.app" ]; then
	echo "❌ Error: Things3 is not installed at /Applications/Things3.app"
	echo "Please install Things3 before running this installer."
	exit 1
fi
echo "✓ Things3 is installed"

# Check if osascript is available
if ! command -v osascript &> /dev/null; then
	echo "❌ Error: osascript command not found"
	echo "AppleScript support is required for this tool."
	exit 1
fi
echo "✓ osascript is available"

# Check if launchctl is available
if ! command -v launchctl &> /dev/null; then
	echo "❌ Error: launchctl command not found"
	echo "launchd support is required for scheduled exports."
	exit 1
fi
echo "✓ launchctl is available"
echo ""

# Load local config if present (overrides default paths without affecting git)
if [ -f "$(dirname "$0")/.local-config.sh" ]; then
	source "$(dirname "$0")/.local-config.sh"
fi

# Define paths
SCRIPT_DIR="$HOME/Scripts"
SNAPSHOT_DIR="${THINGS_SNAPSHOT_DIR:-$HOME/Documents/ThingsSnapshot-fallback}"
LAUNCHD_PLIST="$HOME/Library/LaunchAgents/com.rickarmbrust.things-export.plist"
CURRENT_DIR="$(cd "$(dirname "$0")" && pwd)"
USERNAME=$(whoami)

# Create directories
echo "Creating directories..."
mkdir -p "$SCRIPT_DIR"
mkdir -p "$SNAPSHOT_DIR"
echo "✓ Directories created"
echo ""

# Propagate custom path to AppleScript config file if set
if [ -n "$THINGS_SNAPSHOT_DIR" ]; then
	echo "$THINGS_SNAPSHOT_DIR" > "$HOME/.things-export-path"
	echo "✓ Custom path saved: $THINGS_SNAPSHOT_DIR"
	echo ""
fi

# Copy AppleScript
echo "Installing AppleScript..."
cp "$CURRENT_DIR/export_things_daily_snapshot.scpt" "$SCRIPT_DIR/"
chmod +x "$SCRIPT_DIR/export_things_daily_snapshot.scpt"
echo "✓ AppleScript installed to: $SCRIPT_DIR/export_things_daily_snapshot.scpt"
echo ""

# Copy launchd plist and update username
echo "Installing launchd scheduler..."
sed "s|/Users/USERNAME/|/Users/$USERNAME/|g" "$CURRENT_DIR/com.rickarmbrust.things-export.plist" > "$LAUNCHD_PLIST"
echo "✓ Scheduler plist installed"
echo ""

# Load launchd job
echo "Loading scheduled job..."
launchctl unload "$LAUNCHD_PLIST" 2>/dev/null || true  # Unload if already loaded
launchctl load "$LAUNCHD_PLIST"
echo "✓ Scheduled job loaded (runs daily at 6:00 AM)"
echo ""

# Test the export
echo "Running test export..."
osascript "$SCRIPT_DIR/export_things_daily_snapshot.scpt"
echo "✓ Test export completed"
echo ""

# Check if export file was created
TODAY=$(date +%Y-%m-%d)
EXPORT_FILE="$SNAPSHOT_DIR/${TODAY}_things_snapshot.json"

if [ -f "$EXPORT_FILE" ]; then
	FILE_SIZE=$(wc -c < "$EXPORT_FILE" | tr -d ' ')
	echo "========================================="
	echo "Installation successful!"
	echo "========================================="
	echo ""
	echo "Export file created: $EXPORT_FILE"
	echo "File size: $FILE_SIZE bytes"
	echo ""
	echo "The export will run automatically every day at 6:00 AM."
	echo "You can manually trigger it anytime with:"
	echo "  osascript ~/Scripts/export_things_daily_snapshot.scpt"
	echo ""
	echo "Logs are saved to:"
	echo "  $SNAPSHOT_DIR/export.log"
	echo "  $SNAPSHOT_DIR/export.error.log"
	echo ""
else
	echo "⚠️  Warning: Export file was not created."
	echo "Check the error log: $SNAPSHOT_DIR/export.error.log"
	exit 1
fi

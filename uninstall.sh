#!/bin/bash
set -e

INSTALL_DIR="$HOME/.local/bin"
PLIST_DIR="$HOME/Library/LaunchAgents"

echo "Stopping service..."
launchctl unload "$PLIST_DIR/com.user.g29pedalkeys.plist" 2>/dev/null || true

echo "Removing LaunchAgent..."
rm -f "$PLIST_DIR/com.user.g29pedalkeys.plist"

echo "Removing binary..."
rm -f "$INSTALL_DIR/g29-pedal-keys"

echo ""
echo "Uninstall complete!"
echo "Config preserved at: ~/.config/g29-pedal-keys/"
echo "To remove config: rm -rf ~/.config/g29-pedal-keys"

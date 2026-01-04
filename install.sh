#!/bin/bash
set -e

INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/g29-pedal-keys"
PLIST_DIR="$HOME/Library/LaunchAgents"

echo "Building g29-pedal-keys..."
swift build -c release

echo "Installing binary to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp .build/release/g29-pedal-keys "$INSTALL_DIR/"

echo "Creating config directory..."
mkdir -p "$CONFIG_DIR"

if [ ! -f "$CONFIG_DIR/config.json" ]; then
    echo "Copying default config..."
    cp config.json "$CONFIG_DIR/"
fi

echo "Installing LaunchAgent..."
mkdir -p "$PLIST_DIR"

# Update plist with correct path
sed "s|/usr/local/bin/g29-pedal-keys|$INSTALL_DIR/g29-pedal-keys|g" \
    com.user.g29pedalkeys.plist > "$PLIST_DIR/com.user.g29pedalkeys.plist"

echo "Loading LaunchAgent..."
launchctl unload "$PLIST_DIR/com.user.g29pedalkeys.plist" 2>/dev/null || true
launchctl load "$PLIST_DIR/com.user.g29pedalkeys.plist"

echo ""
echo "Installation complete!"
echo ""
echo "IMPORTANT: Grant permissions in System Settings > Privacy & Security:"
echo "  1. Input Monitoring: Add $INSTALL_DIR/g29-pedal-keys"
echo "  2. Accessibility: Add $INSTALL_DIR/g29-pedal-keys"
echo ""
echo "To test manually: $INSTALL_DIR/g29-pedal-keys --verbose"
echo "To view logs: tail -f /tmp/g29-pedal-keys.log"
echo "To uninstall: ./uninstall.sh"

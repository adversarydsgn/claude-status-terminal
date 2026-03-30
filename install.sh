#!/bin/bash
# Install Claude Status menubar to auto-start on login

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_PATH="$SCRIPT_DIR/Claude Status.app"
PLIST_NAME="com.adversary.claude-status"
PLIST_PATH="$HOME/Library/LaunchAgents/${PLIST_NAME}.plist"

echo "Claude Status Terminal — Installer"
echo "─────────────────────────────────────"
echo ""

if [[ ! -d "$APP_PATH" ]]; then
    echo "Error: Claude Status.app not found at $APP_PATH"
    exit 1
fi

# Create LaunchAgent
mkdir -p "$HOME/Library/LaunchAgents"

cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${PLIST_NAME}</string>
    <key>ProgramArguments</key>
    <array>
        <string>open</string>
        <string>-a</string>
        <string>${APP_PATH}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF

echo "✓ Created LaunchAgent at $PLIST_PATH"
echo "  Menubar app will auto-start on login."
echo ""

# Start it now
launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"
echo "✓ Started Claude Status menubar"
echo ""
echo "You should see two colored dots in your menu bar."
echo "Click them for status details and to open the dashboard."
echo ""
echo "To uninstall:"
echo "  launchctl unload $PLIST_PATH"
echo "  rm $PLIST_PATH"

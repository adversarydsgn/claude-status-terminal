#!/bin/bash
# Install the Claude Status apps into /Applications (so Spotlight/Raycast can
# find them) and auto-start the menubar agent on login.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLIST_NAME="com.adversary.claude-status"
PLIST_PATH="$HOME/Library/LaunchAgents/${PLIST_NAME}.plist"

echo "Claude Status — Installer"
echo "─────────────────────────────────────"
echo ""

# Pick an Applications dir: system-wide if writable, else user-local. Both are
# indexed by Spotlight and Raycast.
APPS_DIR="/Applications"
if [[ ! -w "$APPS_DIR" ]]; then
    APPS_DIR="$HOME/Applications"
    mkdir -p "$APPS_DIR"
    echo "  Note: /Applications not writable — installing to $APPS_DIR"
fi

# Stop any running instance (could be an older copy from a previous location)
# before we replace the bundle.
pkill -f "Claude Status.app/Contents/MacOS/ClaudeStatusMenubar" 2>/dev/null || true

# Deploy the app bundles built by ./build.sh into the Applications dir.
for APP in "Claude Status.app" "Claude Dashboard.app"; do
    SRC="$SCRIPT_DIR/$APP"
    if [[ ! -d "$SRC" ]]; then
        echo "Error: $APP not found in repo — run ./build.sh first." >&2
        exit 1
    fi
    rm -rf "${APPS_DIR:?}/$APP"
    cp -R "$SRC" "$APPS_DIR/$APP"
    echo "✓ Installed $APP → $APPS_DIR"
done
echo ""

APP_PATH="$APPS_DIR/Claude Status.app"

# Create LaunchAgent that opens the installed menubar app at login.
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

# (Re)start it now.
launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"
echo "✓ Started Claude Status menubar"
echo ""
echo "Installed to: $APPS_DIR"
echo "  • Claude Status.app    — menubar status indicator (auto-starts on login)"
echo "  • Claude Dashboard.app — opens the terminal dashboard"
echo "You should see two colored dots in your menu bar."
echo ""
echo "To uninstall:"
echo "  launchctl unload $PLIST_PATH"
echo "  rm $PLIST_PATH"
echo "  rm -rf \"$APPS_DIR/Claude Status.app\" \"$APPS_DIR/Claude Dashboard.app\""

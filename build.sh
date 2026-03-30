#!/bin/bash
# Build Claude Status Terminal — compiles menubar app, generates icon, creates .app bundles
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "Claude Status Terminal — Build"
echo "══════════════════════════════════"
echo ""

# ── Prerequisites ───────────────────────────────────────
echo "Checking prerequisites..."
command -v swiftc >/dev/null 2>&1 || { echo "Error: Xcode Command Line Tools required (xcode-select --install)"; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "Error: Python 3 required"; exit 1; }
python3 -c "from PIL import Image" 2>/dev/null || { echo "Error: Pillow required (pip3 install Pillow)"; exit 1; }
echo "  ✓ All prerequisites met"
echo ""

# ── Generate icon ───────────────────────────────────────
echo "Generating app icon..."
python3 generate-icon.py
echo ""

# ── Compile menubar app ─────────────────────────────────
echo "Compiling menubar app..."
swiftc -O -o claude-status-menubar \
  -framework Cocoa \
  -framework Foundation \
  ClaudeStatusMenubar.swift
echo "  ✓ Compiled claude-status-menubar"
echo ""

# ── Create Claude Status.app (menubar) ──────────────────
echo "Creating Claude Status.app..."
rm -rf "Claude Status.app"
mkdir -p "Claude Status.app/Contents/MacOS"
mkdir -p "Claude Status.app/Contents/Resources"
cp claude-status-menubar "Claude Status.app/Contents/MacOS/ClaudeStatusMenubar"
cp AppIcon.icns "Claude Status.app/Contents/Resources/AppIcon.icns"

cat > "Claude Status.app/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Claude Status</string>
    <key>CFBundleDisplayName</key>
    <string>Claude Status</string>
    <key>CFBundleIdentifier</key>
    <string>com.adversary.claude-status</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>ClaudeStatusMenubar</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST
echo "  ✓ Created Claude Status.app (menubar)"

# ── Create Claude Dashboard.app (terminal launcher) ─────
echo "Creating Claude Dashboard.app..."
rm -rf "Claude Dashboard.app"
mkdir -p "Claude Dashboard.app/Contents/MacOS"
mkdir -p "Claude Dashboard.app/Contents/Resources"
cp AppIcon.icns "Claude Dashboard.app/Contents/Resources/AppIcon.icns"

cat > "Claude Dashboard.app/Contents/MacOS/launch" << EOF
#!/bin/bash
osascript -e 'tell application "Terminal"
    activate
    do script "\"$SCRIPT_DIR/claude-status.sh\""
end tell'
EOF
chmod +x "Claude Dashboard.app/Contents/MacOS/launch"

cat > "Claude Dashboard.app/Contents/Info.plist" << 'PLIST2'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Claude Dashboard</string>
    <key>CFBundleDisplayName</key>
    <string>Claude Dashboard</string>
    <key>CFBundleIdentifier</key>
    <string>com.adversary.claude-dashboard</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>launch</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST2
echo "  ✓ Created Claude Dashboard.app (terminal launcher)"

echo ""
echo "══════════════════════════════════"
echo "Build complete! You now have:"
echo ""
echo "  Claude Status.app     — Menubar status indicator (claude.ai + Claude Code)"
echo "  Claude Dashboard.app  — Opens the full terminal dashboard"
echo "  claude-status.sh      — Run directly: ./claude-status.sh"
echo ""
echo "To auto-start the menubar on login:  ./install.sh"
echo "To add dashboard to Dock:            Drag Claude Dashboard.app to your Dock"

#!/bin/bash
# Quick installer for Claude Status Terminal
# Usage: curl -fsSL https://raw.githubusercontent.com/adversarydsgn/claude-status-terminal/main/install-global.sh | bash
set -euo pipefail

echo ""
echo "  Claude Status Terminal — Installer"
echo "  ═══════════════════════════════════"
echo ""

# Check prerequisites
command -v python3 >/dev/null 2>&1 || { echo "  Error: Python 3 required. Install from python.org or: brew install python"; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "  Error: curl required."; exit 1; }

INSTALL_DIR="$HOME/.claude-status"
BIN_DIR="/usr/local/bin"

# Check if we can write to /usr/local/bin, otherwise use ~/bin
if [[ ! -w "$BIN_DIR" ]]; then
    BIN_DIR="$HOME/bin"
    mkdir -p "$BIN_DIR"
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        echo "  Note: Adding $BIN_DIR to your PATH"
        SHELL_RC="$HOME/.zshrc"
        [[ -f "$HOME/.bashrc" ]] && SHELL_RC="$HOME/.bashrc"
        echo "export PATH=\"\$HOME/bin:\$PATH\"" >> "$SHELL_RC"
    fi
fi

# Download
echo "  Downloading..."
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
curl -fsSL "https://raw.githubusercontent.com/adversarydsgn/claude-status-terminal/main/claude-status.sh" -o "$INSTALL_DIR/claude-status.sh"
chmod +x "$INSTALL_DIR/claude-status.sh"

# Symlink to bin
ln -sf "$INSTALL_DIR/claude-status.sh" "$BIN_DIR/claude-status"

echo "  ✓ Installed to $INSTALL_DIR"
echo "  ✓ Linked to $BIN_DIR/claude-status"
echo ""
echo "  Run it:"
echo "    claude-status"
echo ""
echo "  Uninstall:"
echo "    rm -rf $INSTALL_DIR $BIN_DIR/claude-status"
echo ""

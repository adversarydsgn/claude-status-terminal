```
        *  .    *       .    *    .   *       *    .
    .       *       .       *  .    *    .        *
  *    .  *    .       *       .       *    .  *    .
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░░  🇺🇸  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  🇺🇸  ░░
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

   ██████╗██╗      █████╗ ██╗   ██╗██████╗ ███████╗
  ██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗██╔════╝
  ██║     ██║     ███████║██║   ██║██║  ██║█████╗
  ██║     ██║     ██╔══██║██║   ██║██║  ██║██╔══╝
  ╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝███████╗
   ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝
  ███████╗████████╗ █████╗ ████████╗██╗   ██╗███████╗
  ██╔════╝╚══██╔══╝██╔══██╗╚══██╔══╝██║   ██║██╔════╝
  ███████╗   ██║   ███████║   ██║   ██║   ██║███████╗
  ╚════██║   ██║   ██╔══██║   ██║   ██║   ██║╚════██║
  ███████║   ██║   ██║  ██║   ██║   ╚██████╔╝███████║
  ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚══════╝

  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░░    ★ ★ ★  MADE IN AMERICA  ★ ★ ★    ░░
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
    .  *      .    *   .      *   .    *      .  *
  *       .  *    .       *       .  *    .       *
      *       .       *    .  *       .       *
```

# Claude Status Terminal 🇺🇸

A live-updating terminal dashboard and macOS menubar app for monitoring [Claude](https://claude.ai) service status. Mirrors [status.claude.com](https://status.claude.com) with 90-day uptime history bars, incident tracking, and color-coded health indicators.

Free and open source. No account required. Made in America.

<!-- TODO: Add screenshot -->
<!-- ![Terminal Dashboard](screenshots/dashboard.png) -->

## What You Get

**Terminal Dashboard** (`claude-status.sh`)
- Live status for all 5 Claude services
- 90-day uptime history bars (green/yellow/red per day)
- Calculated uptime percentages
- Active incident details and scheduled maintenance
- Auto-refreshes every 30 seconds

**Menubar App** (`Claude Status.app`)
- Two colored dots in your macOS menu bar — one for claude.ai, one for Claude Code
- Click to see all services at a glance
- Open the terminal dashboard or status.claude.com from the dropdown
- Polls every 60 seconds
- Auto-start on login (optional)

**Dashboard Launcher** (`Claude Dashboard.app`)
- Double-click (or Dock click) to open the terminal dashboard
- Drag to your Dock for quick access

## Requirements

- macOS 12+
- Python 3 (ships with Xcode CLI tools, or `brew install python`)
- `curl` (ships with macOS)

For the menubar app (optional): Xcode Command Line Tools + Pillow (`pip3 install Pillow`)

## Install

### Homebrew (recommended)
```bash
brew tap adversarydsgn/tap
brew install claude-status
```

### One-liner
```bash
curl -fsSL https://raw.githubusercontent.com/adversarydsgn/claude-status-terminal/main/install-global.sh | bash
```

### From source
```bash
git clone https://github.com/adversarydsgn/claude-status-terminal.git
cd claude-status-terminal

# Terminal dashboard only — ready to go:
./claude-status.sh

# Full build (menubar app + dashboard launcher):
pip3 install Pillow  # if you don't have it
./build.sh

# Optional: auto-start menubar on login
./install.sh
```

## Usage

### Terminal dashboard
```bash
claude-status
```
Press `Ctrl+C` to exit.

### Menubar app
```bash
open "Claude Status.app"
```
Or run `./install.sh` to auto-start on login. The menubar shows two dots:
- **Left dot** — claude.ai status
- **Right dot** — Claude Code status

Green = operational, yellow = degraded, orange = partial outage, red = major outage.

### Dashboard launcher
Drag `Claude Dashboard.app` to your Dock. Click to open a new terminal with the dashboard.

## How It Works

- Pulls live data from the [status.claude.com API](https://status.claude.com/api/v2/summary.json) (public, no auth required)
- Scrapes 90-day uptime history from the status page HTML (embedded `uptimeData` JSON)
- Zero external dependencies beyond Python/Pillow (for icon generation) and Swift (for menubar)

## Status Colors

| Color | Meaning |
|-------|---------|
| Green | Operational |
| Yellow | Degraded performance or short partial outage |
| Orange | Partial outage |
| Red | Major outage (4+ hours) |
| Blue | Under maintenance |

## Customization

- **Refresh interval**: Edit `REFRESH=30` at the top of `claude-status.sh` (seconds)
- **Menubar poll interval**: Change `60` in `ClaudeStatusMenubar.swift` line with `Timer.scheduledTimer`
- **Tracked menubar services**: Edit `trackedComponents` array in `ClaudeStatusMenubar.swift`

## Uninstall

Remove the menubar auto-start:
```bash
launchctl unload ~/Library/LaunchAgents/com.adversary.claude-status.plist
rm ~/Library/LaunchAgents/com.adversary.claude-status.plist
```

Delete the repo folder and any Dock shortcuts.

## Contributing

Issues and PRs welcome. This project is maintained with help from Claude Code.

## License

MIT License. See [LICENSE](LICENSE).

---

Built by [Adversary](https://github.com/adversarydsgn). Not affiliated with Anthropic.

# AGENTS.md

## Cursor Cloud specific instructions

This is a macOS-focused project (Claude Status Terminal) with no package manager, no build system beyond shell scripts, and no automated test suite. The core product is `claude-status.sh`, a bash script with inline Python 3 that fetches live data from `status.claude.com`.

### Platform constraints

- The **menubar app** (`ClaudeStatusMenubar.swift`) and **icon generator** (`generate-icon.py` → `iconutil`) require macOS + Xcode CLI tools. These cannot be built or tested on Linux.
- The **terminal dashboard** (`claude-status.sh`) runs on Linux with Python 3 + curl + bash and is the primary component to validate.

### Validation commands (Linux-compatible)

- **Shell syntax check:** `bash -n claude-status.sh`
- **API reachability + JSON structure:** replicate the steps in `.github/workflows/health-check.yml` (`api-check` job) using `python3` and `curl`.
- **Uptime scrape check:** fetch `https://status.claude.com/` and verify `uptimeData` JSON is parseable.
- **Run the dashboard (single render):** execute the inline Python block from `claude-status.sh` directly, since the full script enters an interactive loop with `tput civis` / key reads that require a TTY.

### No linter or test framework

There is no linter, formatter, or test framework configured. The CI workflow (`.github/workflows/health-check.yml`) performs the only automated checks: API validation, uptime scrape, shell syntax, and macOS-only build verification.

### Running the dashboard interactively

To run `./claude-status.sh` interactively (with auto-refresh and key bindings), a real terminal (TTY) is required. In headless environments, extract and run the `render()` function's Python block directly for a single-shot render.

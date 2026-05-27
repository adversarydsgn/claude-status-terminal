# AGENTS.md

## Cursor Cloud specific instructions

This is a zero-dependency bash + Python project (no package manager, no lockfiles). The core product is `claude-status.sh`, a terminal dashboard for monitoring Claude service status.

### Running the application

```bash
./claude-status.sh
```

The script runs in a loop (refreshes every 30s). Press `q` to quit, `r` to refresh manually.

### Linting

- **Shell**: `shellcheck claude-status.sh` (warnings are informational; the CI only runs `bash -n claude-status.sh` for syntax validation)
- **Python**: The embedded Python in `claude-status.sh` uses only stdlib (`json`, `urllib.request`, `re`, `sys`, `os`). No external packages needed.
- There is no formal test suite — the CI workflow (`.github/workflows/health-check.yml`) validates the API fetch, JSON structure, uptime scraping, and shell syntax.

### CI checks (reproducible locally)

```bash
bash -n claude-status.sh                              # shell syntax check
shellcheck claude-status.sh                           # static analysis (informational warnings only)
curl -s "https://status.claude.com/api/v2/summary.json" | python3 -m json.tool > /dev/null  # API reachable
```

### Platform notes

- The macOS menubar app (`ClaudeStatusMenubar.swift`) and icon generator (`generate-icon.py`) require macOS + Swift/Xcode CLI tools + Pillow. These cannot be built on Linux.
- On Linux (Cloud Agent VMs), only the terminal dashboard is runnable.
- The script fetches live data from `status.claude.com` — it requires network access to function.

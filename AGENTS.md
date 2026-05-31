# AGENTS.md — claude-status

Agent build-surface notes for this repo. claude-status is a **public, OSS (MIT)**
macOS status monitor: a bash terminal dashboard, a Swift menubar app, a Python
icon generator, and bash build/install scripts. It reads only the **public**
status.claude.com API — no auth, no credentials.

## Build + test

- **Terminal dashboard:** `./claude-status.sh` (bash + inline `python3`, no deps).
- **Full build (menubar + launcher):** `./build.sh` — needs Xcode Command Line
  Tools (`swiftc`) and Pillow (`pip3 install Pillow`). Produces
  `claude-status-menubar` and the `.app` bundles.
- **Install auto-start:** `./install.sh` (LaunchAgent); `./install-global.sh`
  for the `/usr/local/bin` (or `~/bin`) shim.
- All shell scripts run under `set -euo pipefail` — quote expansions and guard
  external-tool calls with `command -v`.
- Build artifacts are gitignored (`claude-status-menubar`, `*.app/`,
  `AppIcon.icns`, `__pycache__/`, `_artifacts/`). Never stage them.

## Secrets — bright lines (build-time prevention)

This repo has **no secrets**: no API keys, no tokens, no `.env`. It talks only
to the public status.claude.com API. Secrets live in **BWS** (via macOS keychain
machine tokens), never in committed files — and none belong here. Introducing
any credential, auth header, or `.env` loading into a public status reader is a
mistake and a leak vector; don't.

- **Never** print, log, or return a secret *value* — not in `print`/`logger`,
  not in an error message or stack trace, not in a test fixture.
- **Never** presence-check a secret by substituting it. In shell, use
  `[ -n "$X" ]` or `${#X}` — **never** `${VAR:-…}` (it prints the value; this
  was the FRIC-232 leak).
- **Never** add `.env`-based secret plumbing — this project needs none.
- This is enforced two more ways: review-time (`.cursor/BUGBOT.md`) and a hard
  gate (`gitleaks` CI + optional `.githooks/pre-push`). Enable the local hook
  once per clone: `git config core.hooksPath .githooks` (needs `brew install
  gitleaks`).

# Bugbot Review Guidelines — claude-status

## Constitutional — Adversary (synced from adversary-skills, do not edit here)

PR-review rules for internal Adversary repos. Flag concrete, line-level
violations as review comments. Keep findings specific and checkable — do not
flag architectural style, naming taste, or speculative issues. False positives
train us to ignore Bugbot.

### Secrets — highest priority (every leak costs a rotation)
- Flag ANY secret value reaching an output sink: `echo`/`printf`/`print`/
  `console.log`, a logger call (`logger.info(token)`), an **error message or
  stack trace**, a **test fixture / snapshot**, or a bare `$SECRET` in a command
  whose stdout is shown.
- Flag `${VAR:-default}`-style expansion on secret-bearing vars — it substitutes
  and prints the value (this is the FRIC-232 leak). Presence-check by length or
  boolean only (`[ -n "$X" ]`, `${#X}`), never by value.
- Flag hardcoded credentials: `*_KEY`/`*_TOKEN`/`*_SECRET` literals, `sk-…`,
  `ghp_…`, `xox…`, `AKIA…`, PEM private-key blocks.
- Flag a **real value committed** to `.env*`, config, JSON, or fixtures. Secrets
  live in BWS (via macOS keychain machine tokens), never in committed files.
- Flag a credential-retrieval result reaching stdout unfiltered:
  `security find-generic-password … -w` echoed, or `bws secret get`/`bws secret
  list` output not narrowed to key/id (never the value).
- Flag NEW `.env`-based secret loading as architectural drift — secrets come
  from BWS/keychain, not new dotenv plumbing.

### Git & build hygiene
- Flag committed generated files (`next-env.d.ts`-class, build output, vendored
  artifacts) and lockfile churn unrelated to the change.
- Flag unrelated files swept into a scoped PR. Staging is explicit-path only —
  never `git add -A`/`git add .`.

### Hardcoded paths & portability
- Flag absolute machine paths (`/Users/<name>/…`), hardcoded hostnames, or
  embedded environment assumptions. Prefer config/env (OSS-first discipline).

### Deletion & destructive ops
- Flag `rm -rf`, mass deletes, or substrate deletes (DB rows, files, branches)
  with no guard or archive/sequester path. Copy-before-mutate on irreversible
  or external-state operations.

## Repo-specific (edit freely)

claude-status is a **public, OSS (MIT) macOS status monitor**: a bash terminal
dashboard (`claude-status.sh`), a Swift menubar app (`ClaudeStatusMenubar.swift`),
a Python icon generator (`generate-icon.py`), and bash build/install scripts.
It talks only to the **public** status.claude.com API — there are no
credentials, no auth, no `.env` in this project. That makes "no secret ever
appears" and "stays clean enough to publish" the live constraints.

- **No secrets exist here, keep it that way:** this repo has no API keys or
  tokens. Flag the *introduction* of any credential, `.env` loading, auth
  header, or BWS/keychain call — it does not belong in a public status reader
  and is almost certainly a mistake or a leak vector.
- **Public-repo hygiene:** everything here ships to a public GitHub repo. Flag
  any absolute local path (`/Users/adversary/…`), personal hostname, internal
  URL, or machine-specific assumption. Installer/script URLs must point at the
  public `adversarydesign/claude-status*` GitHub raw paths, not local paths.
- **Self-update safety (`claude-status.sh` `self_update`):** the script
  overwrites its own file (`cp "$tmp" "$SELF"`) and `exec`s the new version.
  Flag changes that fetch over plain `http://`, drop `--max-time`/`-fsSL`,
  write the downloaded copy before integrity/version checks, or remove the
  `mktemp`→verify→replace ordering. A poisoned fetch here is RCE on the user's
  machine.
- **Bash robustness:** every shell script runs under `set -euo pipefail`. Flag
  unquoted expansions (`$VAR` that should be `"$VAR"`), unguarded `cp`/`rm`/
  `mv`, and missing `command -v <tool>` prerequisite checks before invoking
  `swiftc`, `python3`, `curl`, or `launchctl`.
- **Network input is untrusted:** the dashboard parses live JSON/HTML from
  status.claude.com (`urllib`, regex scrape of embedded `uptimeData`). Flag
  parsing that can crash the render loop on missing/malformed fields instead of
  degrading gracefully, and any `eval`/shell-interpolation of fetched content.
- **Build/install correctness:** `build.sh` compiles the Swift binary and
  assembles the `.app` bundles; `install*.sh` writes a LaunchAgent plist and a
  `/usr/local/bin` (or `~/bin`) shim. Flag changes that hardcode a user home,
  skip the writable-dir fallback, or generate an unsigned plist with wrong
  paths.
- **Don't commit build artifacts:** `claude-status-menubar`, `*.app/`,
  `AppIcon.icns`, `__pycache__/`, `.DS_Store`, and `_artifacts/` are
  gitignored build/local output. Flag any PR that stages them.

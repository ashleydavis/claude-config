# agent-config

**Skills and slash commands have moved** to [`~/skills/agent-skills`](https://github.com/ashleydavis/agent-skills). Install them with `skl -g add ashleydavis/agent-skills --ns me`.

Personal Claude Code and Cursor global configuration: instructions, settings, and permissions rules.

## Layout

```
home/
├── .claude/
│   ├── CLAUDE.md          # Global Claude instructions
│   ├── settings.json      # Claude Code settings (permissions, hooks)
│   ├── permissions.yaml   # Top-level permissions config
│   └── permissions.d/     # Modular permissions rules (compiled into settings)
└── .cursor/
    └── AGENTS.md          # Global Cursor instructions
```

The `home/` subdirectory is the GNU Stow "package". Its contents are symlinked into `$HOME`.

## Prerequisites

GNU Stow:

```bash
# Ubuntu/Debian
sudo apt install stow

# macOS
brew install stow
```

### Companion plugins

`settings.json` wires in hooks that shell out to two other repos. Both must be cloned into `$HOME` (the paths are hard-coded in the hook commands) and have their dependencies installed before Claude Code will run cleanly:

- [`expressive-permissions`](https://github.com/ashleydavis/expressive-permissions): provides the `PreToolUse` and `PostToolUse` hooks (`~/expressive-permissions/src/pre-hook.ts`, `post-hook.ts`).
- [`claude-tools-runner`](https://github.com/ashleydavis/claude-tools-runner): provides the `Stop` hook (`~/claude-tools-runner/src/stop-hook.ts`).

Both hooks are invoked via `bun`, so `bun` must be on `PATH` as well.

## Install

```bash
git clone <repo-url> ~/agent-config
cd ~/agent-config
./bootstrap.sh
```

`bootstrap.sh` symlinks the individual config entries under `home/.claude/` and `home/.cursor/` into `~/.claude/` and `~/.cursor/` (so `~/.claude/CLAUDE.md` → `~/agent-config/home/.claude/CLAUDE.md`, `~/.cursor/AGENTS.md` → `~/agent-config/home/.cursor/AGENTS.md`, etc.).

### Why bootstrap doesn't just run `stow home`

The stow package contains `home/.claude` and `home/.cursor`. If either `~/.claude` or `~/.cursor` does not already exist, stow performs **tree folding** and makes that path itself a single symlink into this repo. The tool then writes all of its runtime state through that symlink, dumping it into the repo working tree.

To prevent this, `bootstrap.sh` ensures both targets are **real directories** before stowing, so only the individual config files/dirs are symlinked and runtime state stays in the real home dirs. The script is idempotent and self-healing: if it finds either path already folded into a single symlink, it un-folds it and moves any non-tracked runtime state back out of the repo. It also replaces stale package-entry symlinks that point outside this repo (e.g. leftovers after a directory rename) and `--adopt`s plain-file conflicts so a re-run does not abort.

## Uninstall

```bash
cd ~/agent-config
stow -D -t "$HOME" home
```

Removes the symlinks but leaves the files in this repo.

## Testing the permissions rules

Every rule under `home/.claude/permissions.d/` carries an `examples:` block: real commands listed under the decision each one should produce.

```yaml
    tag:
      options:
        - l|list
      decide: allow
      reason: Readonly git access (listing tags only)
      examples:
        allow:
          - git tag --list
          - git tag -l "v*"
        ask:
          - git tag v1.0.0
          - git tag -d v1.0.0
```

`allow` and `deny` list what the rule is meant to decide. `ask` lists the near misses it deliberately leaves alone: nothing matches them, so they fall through to a prompt. An entry is either a command string, or `cmd` plus the `cwd` the command runs in when the rule matches on the working directory. A relative `cwd` resolves against the stand-in project described below, and the examples in this repo use relative paths, so no rule names a directory that only exists on one machine. Non-Bash rules (Read, Write, Edit, WebFetch, MCP and other tools) use the prefix syntax: `read <path>`, `write <path>`, `webfetch <url>`, `tool <name>`, and the Read, Write and Edit examples name an absolute path under that stand-in project, for example `read /project/readme.md`.

The [`permissions` workflow](.github/workflows/permissions.yml) runs these on every push and pull request. It checks out [expressive-permissions](https://github.com/ashleydavis/expressive-permissions) beside this repo's checkout and, from the engine checkout, runs `bun run check-config ../agent-config/home`. That decides every example with the real permissions engine, calling it directly rather than through the REPL, and fails when a rule stops deciding what it says it decides, or when a rule has no example at all.

To run the same check locally, with the engine cloned beside this repo as `expressive-permissions` (the location the prerequisites above describe), starting from this repo's root:

```bash
cd ../expressive-permissions
bun install
bun run check-config ../agent-config/home
```

The one argument is the `.claude` directory holding the rules, and the rules load from there. The examples themselves are decided against a stand-in project directory, `/project`: that is what `${{PROJECT_DIR}}` expands to while checking, what a relative `cwd` resolves against, and the working directory an example runs in unless it names its own. It does not have to exist, which is why no example in this repo names a directory belonging to one machine. Add `--filter <text>` to check one file or one command, and `--list` to print the collected examples without checking them.

## Turning the plugin off in one repo

Global hooks in `home/.claude/settings.json` always run. Claude's `bypassPermissions` mode does **not** skip them. A project cannot remove user hooks by setting `hooks` in `.claude/settings.json`; those arrays merge.

From inside a repo, `/permission:bypass:on` writes `.claude/settings.local.json` (bypass + plugin off). `/permission:bypass:off` removes those keys. Both touch only that file, never global config. Start a new Claude session after either command.

To skip expressive-permissions by hand, put this in that repo's `.claude/settings.local.json`:

```json
{
  "permissions": {
    "defaultMode": "bypassPermissions"
  },
  "env": {
    "EXPRESSIVE_PERMISSIONS": "off"
  }
}
```

You need both: `bypassPermissions` stops Claude's own prompts; `EXPRESSIVE_PERMISSIONS=off` stops the plugin. The plugin still has to be a version that honours that env var.

`disableAllHooks: true` in the same file also works, but it turns off every hook for that repo, not only permissions.

Do not set `bypassPermissions` in this global `settings.json`. Enable it only in the repos that need it.

## Cursor troubleshooting

Notes from hardening Agent shell approvals. Prefer Cursor's docs over memory when something drifts.

### Agent runs `git commit` (and similar) with no approval card

**1. Clear the Command Allowlist cruft**

Path in the UI: **Settings → Agents → Executions and Approvals → Allowlist Options → Command Allowlist**.

A long list builds up over time from "add to allowlist" approvals. Matching is by **prefix** ([permissions.json reference](https://cursor.com/docs/reference/permissions)): an entry like `git -C` matches `git -C <path> commit ...`, so a broad prefix silently auto-runs dangerous git writes.

Action taken: removed all accumulated Command Allowlist entries there so the list is empty again.

That list is IDE state, not a file in this repo. Cursor stores it in app state (`composerState.yoloCommandAllowlist` in the Cursor `state.vscdb` under the user config directory). Optional file override: `~/.cursor/permissions.json` with `terminalAllowlist` (see the same docs). When that file is absent, the IDE list is what counts.

**2. Turn off Auto-review (use Allowlist Run Mode)**

After clearing the allowlist, `git commit` can still run with no card under **Auto-review**: non-allowlisted shell calls may be approved by the classifier without showing you a prompt ([Run Modes](https://cursor.com/docs/agent/security/run-modes)). Auto-review is not a hard security boundary; the docs say the classifier can allow calls you would have blocked.

Path in the UI: **Settings → Agents → Approvals & Execution** → **Run Mode**.

Action taken: set Run Mode to **Allowlist** (classifier: no). With an empty Command Allowlist, non-allowlisted commands should prompt. Docs note that **Ask Every Time** was deprecated; empty Allowlist is the replacement for that behavior.

**3. Do not confuse this with `~/.cursor/cli-config.json`**

That file is the **CLI** permissions allowlist. The IDE Agent Command Allowlist is separate. Editing only `cli-config.json` does not fix IDE Agent auto-run of `git commit`.

**4. Disable Cursor importing Claude config**

Path in the UI: **Settings → Rules, Skills, Subagents** → turn off **Include Third-Party Plugins, Skills, and Other Configs**.

Action taken: disabled that toggle so Cursor does not automatically load Claude configuration (including Claude `PreToolUse` / `PostToolUse` hooks from `~/.claude/settings.json`). Those hooks are built for Claude Code's allow/deny/ask model. Cursor can mishandle `ask` and fail open, which can let commands (for example `git commit`) run without a real approval prompt. See Cursor's [third-party hooks](https://cursor.com/docs/reference/third-party-hooks) docs.

Claude Code itself is unaffected; it still loads `~/.claude/settings.json` as usual.

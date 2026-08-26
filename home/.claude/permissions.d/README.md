# permissions.d

Drop-in permission rule files for Claude Code. Each `.yaml` file is loaded as its own isolated rule layer on top of `~/.claude/permissions.yaml`.

Files are discovered in lexicographic order. A `deny` in any file wins over `allow` rules in sibling files.

## Files

| File | Purpose |
|---|---|
| `bash-bun-readonly.yaml` | Allow readonly `bun`/`bunx` invocations (version/help info, `pm ls/bin/hash`, `why`) |
| `bash-bun-write.yaml` | Allow `bun install` and `bun run` within the current project |
| `bash-node-readonly.yaml` | Allow readonly `node` invocations (version/help, `--check` syntax check) |
| `bash-npm-readonly.yaml` | Allow readonly `npm` subcommands (`ls`, `config get`, `root`, `pkg get`, etc.) and `npx` version/help |
| `bash-gh-readonly.yaml` | Allow readonly `gh` subcommands (view, list, status, checks, etc.) |
| `bash-git-readonly.yaml` | Allow readonly `git` subcommands (log, diff, status, show, etc.) |
| `bash-git-write.yaml` | Deny destructive git ops; allow the worktree merge flow (`rebase` in a worktree, `merge --ff-only`, `worktree remove`, `branch -d`); require approval for commit, push, checkout, etc. |
| `bash-helm-readonly.yaml` | Allow readonly `helm` subcommands (get, list, show, status, etc.) |
| `bash-kubectl-readonly.yaml` | Allow readonly `kubectl` subcommands (get, describe, logs, top, etc.) |
| `bash-mkdir-write.yaml` | Allow `mkdir` within the current project or `/tmp` |
| `bash-readonly.yaml` | Allow common read-only utilities (cat, ls, find, grep, sed, jq, etc.) |
| `bash-tmp-write.yaml` | Allow `tee` to write to `/tmp` |
| `bash-wrappers.yaml` | Allow `mise`, `timeout` and `xargs`; the command each one runs keeps its own decision |
| `claude-tools-readonly.yaml` | Rules for Claude Code tool-name patterns (readonly) |
| `claude-tools-write.yaml` | Rules for Claude Code tool-name patterns (write/mutating) |
| `file-tools-readonly.yaml` | Rules for Read/Grep file tool calls |
| `file-tools-write.yaml` | Rules for Write/Edit/MultiEdit file tool calls |
| `mcp-atlassian-readonly.yaml` | Allow readonly Atlassian MCP tool calls |
| `mcp-permissions-analyzer-readonly.yaml` | Allow the permissions analyzer MCP tool |
| `mcp-photosphere.yaml` | Allow Photosphere MCP tool calls |

## commands/

Command descriptor files that tell the Bash parser which flags take values (arity 1) and which are boolean (arity 0). See [commands/README.md](commands/README.md).

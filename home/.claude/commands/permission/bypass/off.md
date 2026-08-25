---
description: Turn bypass off in this repo. Writes .claude/settings.local.json only.
---

Turn **bypass off** for this repo: stop `bypassPermissions` and turn the expressive-permissions plugin back on.

Do **not** edit `~/agent-config` or `~/.claude/settings.json`. Do **not** edit `.claude/settings.json` in the repo. Only create or update **`.claude/settings.local.json`** at the project root (gitignored local Claude settings).

1. Read `.claude/settings.local.json` if it exists. If it is missing, treat it as `{}`.
2. Merge so the result does **not** force allow-all:
   - Delete `permissions.defaultMode` if it is `bypassPermissions` (leave any other `defaultMode` alone).
   - Delete `env.EXPRESSIVE_PERMISSIONS`.
   - If `permissions` or `env` is then empty, delete that object.
   - Keep every other key already in the file.
3. Write the file with the Write or Edit tool (pretty-printed JSON). If the file would be `{}` and you created it only for this, deleting the file is also fine.
4. Say that a **new Claude Code session** in this repo is required for `defaultMode` and hook env to take effect.

Do not run git, do not commit, do not touch global config.

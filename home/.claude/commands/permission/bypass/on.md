---
description: Turn bypass on in this repo. Writes .claude/settings.local.json only.
---

Turn **bypass on** for this repo: Claude `bypassPermissions` plus the expressive-permissions plugin skipped.

Do **not** edit `~/agent-config` or `~/.claude/settings.json`. Do **not** edit `.claude/settings.json` in the repo. Only create or update **`.claude/settings.local.json`** at the project root (gitignored local Claude settings). Global hooks still run; `bypassPermissions` does not skip them. `EXPRESSIVE_PERMISSIONS=off` is what makes the plugin allow everything.

1. Read `.claude/settings.local.json` if it exists. If it is missing, treat it as `{}`.
2. Merge these keys, keeping every other key already in the file:

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

3. Write the file with the Write or Edit tool (pretty-printed JSON). Create `.claude/` first if needed.
4. If `.gitignore` does not already ignore `.claude/settings.local.json`, add that line. Do not commit.
5. Say that a **new Claude Code session** in this repo is required for `defaultMode` and hook env to take effect.

Do not run git commit, do not push, do not touch global config.

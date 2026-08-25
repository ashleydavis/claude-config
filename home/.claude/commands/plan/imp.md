Implement the current plan.

0. **Choose the plan** — if a specific plan is obvious from the conversation context, use that. Otherwise list the 5 most recent files in `docs/plans/new/` (by modification time) and present them as a numbered menu for the user to choose from. Wait for the user's selection before continuing.

1. **Choose working location** — present the user with:
   ```
   1. Main working copy
   2. Git worktree
   ```
   Wait for the user to reply with 1 or 2. If they choose 2: (1) run `git branch --show-current` to get the current branch, (2) run `git worktree add -b <new-branch> .claude/worktrees/<name> <current-branch>` to create the worktree branching from the current branch, (3) use `EnterWorktree` with the `path` parameter to enter it, then run `bun install '*'` inside it before proceeding.

   **If the user chose the worktree (option 2) you MUST actually work inside that worktree for the entire task. This is not optional.** Every file edit, every command, every commit must happen inside the worktree, never in the main repo. It is NOT acceptable to make changes to the main working copy when the user chose the worktree, not even a small edit, a quick fix, a test tweak, or "just this once". Before you edit or run anything, confirm your working directory is the worktree path. If you ever notice you are in the main repo, stop immediately and move to the worktree.

   Understand the consequences, because YOU have repeatedly broken this rule: if you make ANY change to the main repo when you were supposed to be on the worktree, those changes will be summarily reverted without asking you and without consulting you. Your work will be thrown away. And if you keep violating this rule and continue making changes to the main repo, your process will be summarily terminated. Reverted changes and a terminated process is the guaranteed outcome of working in the main repo when the worktree was chosen. Use the worktree.

2. **Read the plan** — read the chosen plan file from `docs/plans/new/`.

3. **Check for open issues** — look at the top of the plan file for an issues section with checkboxes. If any unchecked items (`- [ ]`) exist, stop and report them to the user before proceeding. Only continue if all issues are checked off (`- [x]`).

4. **Create a todo list** — use TodoWrite to break the plan into discrete tasks, then work through them one by one, marking each complete as you go.

5. **Documentation stop** — if the plan's first step is write documentation, do that step and then STOP. Do not start later steps. Do not write tests, verify, or move the plan. Tell the human the documentation is ready for review and wait for them to approve it. If they revise the documentation, revise the remaining plan steps to match, then wait for them to say to continue. Only after that approval may you implement later steps. The last step, when present, updates the documentation to match the final code.

6. **Write tests** — add or update unit tests and smoke tests for every new or changed function as described in the plan.

7. **Verify** — once all steps are done, run `/verify` to confirm the full test suite and compile checks pass.

8. **Move the plan** — move the plan file (and the plans "steps" directory if it has one) from `docs/plans/new/` to `docs/plans/done/`.

9. **Report** — summarise what was implemented and flag anything that was skipped or deferred.

## Next

Recommend the developer run:
- After a write-documentation step, wait for the human to approve the docs (and revise remaining plan steps if they changed the docs) before continuing implementation.
- `/verify`: run all quality checks once implementation is complete.
- `/commit:detz`: once checks pass, produce a commit message.

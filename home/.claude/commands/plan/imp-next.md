Implement the next step of the current plan.

This command is for plans that have been broken into discrete step files (via `/plan:break`). It implements one step at a time, marks it complete in the plan's checklist, and records what was done in the step file's Summary section.

0. **Choose the plan** — if a specific plan is obvious from the conversation context, use that. Otherwise list the 5 most recent files in `docs/plans/new/` (by modification time) and present them as a numbered menu for the user to choose from. Wait for the user's selection before continuing.

1. **Read the plan and find the next step** — read the chosen plan file from `docs/plans/new/`. Locate the `## Implementation Steps` checklist at the top of the file. Find the first unchecked item (`- [ ]`). If every item is already checked (`- [x]`), stop and tell the user the plan is fully implemented.

2. **Confirm with the user** — show the user which step is next (its number, title, and step file path) and ask them to confirm before proceeding. Wait for confirmation.

3. **Read the step file** — read the specific step file referenced by the next unchecked checklist item (e.g. `docs/plans/<plan-name>/<N>-<slug>.md`).

4. **Create a todo list** — use TodoWrite to break the step into discrete tasks, then work through them one by one, marking each complete as you go.

5. **Write tests** — add or update unit tests and smoke tests for every new or changed function as described in the step.

6. **Verify** — once all tasks for this step are done, run `/verify` to confirm the full test suite and compile checks pass.

7. **Update the step file's Summary** — replace the empty `## Summary` placeholder at the bottom of the step file with a concise account of what was actually done: files changed, key decisions, anything that diverged from the original step instructions, and anything deferred.

8. **Mark the step complete** — in the plan file's Implementation Steps checklist, change the `- [ ]` for this step to `- [x]`.

9. **If this was the last step, move the plan** — if every item in the Implementation Steps checklist is now `- [x]`, move the plan file and its steps directory from `docs/plans/new/` to `docs/plans/done/`. Otherwise leave the plan in `new/`.

10. **Report** — summarise what was implemented in this step, flag anything that was skipped or deferred, and tell the user which step (if any) is next.

    **Documentation stop.** If the step just completed was "Write documentation" (the first step of a plan that needs docs), STOP here. Do not implement the next step. Tell the human the documentation is ready for review and wait for them to approve it. If they revise the documentation, revise the remaining plan steps to match, then wait for them to say to continue. Only after that approval may `/plan:imp-next` be run again. When the last step is "Update documentation", it revises the docs from step 1 to match the final code.

## Next

Recommend the developer run:
- `/plan:imp-next`: implement the next step, repeating until the plan is done. After a write-documentation step, do not run this until the human has approved the documentation (and remaining steps have been revised if they changed the docs).
- `/verify`: once all steps are done.

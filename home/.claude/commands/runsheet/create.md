Interview the human and create a new runsheet as a local markdown file under `runsheets/`.

Follow the runsheet style guide available in `~/notes`. Do not invent a parallel style.

## Steps

1. **Interview (ask only what you still need).** Gather enough to draft a complete runsheet. Prefer one short questionnaire, then fill gaps. Cover procedure name, what the operator is doing, environments, repos/tools, tickets, inputs, Before/During/After steps, rollback, exceptions, related resources, roles if more than one acts, and whether it supersedes an older page. Do not invent ticket types, workflows, or approvals the human did not confirm.

2. **Draft locally** to `runsheets/<slug>.md` (kebab-case from the title), following the runsheet style guide available in `~/notes`.

3. **Do not publish to Confluence** as part of this command unless the human explicitly asks. Creating the local draft is the default deliverable. If they want it live after review, use `/runsheet/publish`.

4. **Report.** Path to the new file and any open questions still blocking a publish-ready runsheet.

## Hard stops

- Never use em dashes in the draft. Use a period, comma, colon, or parentheses instead.

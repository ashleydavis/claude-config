Create a new plan and save it to `docs/plans/`.

**Important:** You are drafting this plan for an AI agent (Claude) to execute later, not for a human. Do not write steps a human would follow. Write steps as precise AI actions: file edits, function changes, tool calls, and code modifications with exact file paths and names.

1. **Gather intent** — if the user has described the feature or change in this conversation, use that. Otherwise ask: "What do you want to plan?" Wait for their answer before continuing.

2. **Research** — explore the relevant parts of the codebase to understand the current structure, affected files, and any existing patterns that the plan should follow. Use file reads, grep, and directory listings as needed.

3. **Draft the plan** — produce a complete plan using the structure below. Be specific: name actual files, functions, types, and interfaces. Steps should be small enough to implement one at a time. **Write all steps as instructions for an AI agent to execute, not a human** — steps should describe precise code changes, file edits, and tool actions, not manual UI interactions or things a person would do. Plans may include interface, class, and function signatures where helpful. Do not include actual implementation code unless describing a particularly difficult algorithm. Requirements should be described as text or bullet points, not code.

    **Documentation steps.** Many plans need documentation. Not all do. If the change is something a later reader would need documented (user-facing behaviour, public API, config, commands, or similar), the plan must start with a documentation step and end with a documentation-update step. Skip both when the change has no documented surface (for example an internal-only refactor). If it is not clear, ask the human.

    - **First step: write documentation.** Draft the documentation for the feature or change as it is intended to work, naming the actual doc files to create or update, so the human can read it and understand what they are getting before any code is written. This step must tell the executing agent to STOP when the draft is written: do not continue to later steps. Wait for the human to review and approve the documentation. The human may revise the documentation. Those revisions must be reflected as revisions to the remaining plan steps before implementation continues.
    - **Last step: update documentation.** After the code is in place, revise the documentation from step 1 so it matches the final code, including anything that changed during implementation.

```
# <Plan Title>

## Overview
<One paragraph describing the intent and why the change is needed>

## Issues
<Leave empty — populated later by plan:check>

## Steps
<Numbered list of concrete implementation steps, each naming the file and function to change. When the change needs documentation, step 1 is write documentation (then STOP and wait for human approval; revise later steps if the human revises the docs) and the last step is update documentation to match the final code. Each step that produces code must require that the code compiles (or type-checks / builds cleanly for the language) and that tests pass before it is complete: every new or changed function gets a unit test, and behaviour gets an e2e/smoke test where possible. Exception: React components, contexts, and hooks are not unit tested but must be covered by an e2e test.>

## Unit Tests
<List of unit tests to write or update — one per new or changed function. Every function must have a unit test. Exception: React components, contexts, and hooks are not unit tested (cover them with end-to-end tests instead).>

## Smoke Tests
<List of end-to-end checks, preferably captured as automated tests in a shell script. Where possible every behaviour should be covered by an end-to-end or smoke test. React components, contexts, and hooks must be covered here since they are not unit tested.>

## Verify
<Concrete, observable checks the AI agent can run after implementation. Must always include: the code compiles (or type-checks / builds cleanly for the language), all unit tests pass, and all smoke/e2e tests pass.>

## Notes
<Decisions, trade-offs, open questions, or constraints discovered during research>
```

4. **Choose a filename** — derive a short kebab-case name from the plan subject (e.g. `plan-add-user-auth.md`). If a file with that name already exists in `docs/plans/new/`, choose a different name.

5. **Save** — write the plan to `docs/plans/new/<filename>`.

6. **Report** — print the path of the saved file and a one-line summary of what the plan covers.

## Hard stops

- Never use em dashes in the plan. Use a period, comma, colon, or parentheses instead.

## Next

Recommend the developer run:
- `/plan:check`: analyse the new plan for problems.
- `/plan:simp`: if the plan looks over-engineered, propose simplifications.

Save the current plan to a markdown file in `docs/plans/new/`.

1. **Identify the plan** — use the plan from the current conversation context. If none is clear, ask the user to describe the plan before proceeding.

2. **Choose a filename** — derive a short kebab-case name from the plan's subject (e.g. `plan-add-user-auth.md`). If a file with that name already exists, choose a different name.

3. **Write the file** — save to `docs/plans/new/<filename>`. Structure the content as:

```
# <Plan Title>

## Overview
<One paragraph describing the intent>

## Steps
<Numbered list of implementation steps. When the change needs documentation, step 1 is write documentation (then STOP and wait for human approval; revise later steps if the human revises the docs) and the last step is update documentation to match the final code.>

## Unit Tests
<Unit tests to write or update>

## Smoke Tests
<Smoke tests to write or update>

## Verify
<Concrete checks to confirm after implementation is complete>

## Notes
<Any decisions, trade-offs, or open questions>
```

4. **Report** — print the path of the saved file.

## Next

Recommend the developer run:
- `/plan:check`: analyse the saved plan for problems.

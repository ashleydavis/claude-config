Break the current plan into discrete implementation steps.

Use the plan from the current conversation, or read the most recent 5 files in `docs/plans/new/` and ask the user which to use.

## Steps

1. Read the plan and identify logical, self-contained chunks of work. Each chunk should be small enough to implement and verify independently, but large enough to be meaningful. Every step must produce file output (code, tests, or documentation). Do not create steps that only involve reading, researching, or planning with no written output. Do not create steps that only scaffold empty directories with no actual files.

2. Many plans need documentation. Not all do. If the change is something a later reader would need documented (user-facing behaviour, public API, config, commands, or similar), the **first step** is "Write documentation": draft the documentation for the feature or change as it is intended to work, naming the actual doc files to create or update, so the human can read it and understand what they are getting before any code is written. The step must tell the executing agent to STOP when the draft is written: do not continue to later steps. Wait for the human to review and approve the documentation. The human may revise the documentation. Those revisions must be reflected as revisions to the remaining plan steps before implementation continues. Save it to `docs/plans/<plan-name-without-extension>/1-write-documentation.md`. Skip this step when the change has no documented surface (for example an internal-only refactor). If it is not clear, ask the human.

3. For each middle step (the actual implementation steps):
   - If it involves adding or changing code, the step must require that the code compiles (or type-checks / builds cleanly for the language) before the step is complete.
   - The step must include writing or updating tests:
     - Every new or changed function must have a unit test.
     - Where possible, behaviour must also be covered by an end-to-end or smoke test.
     - Exception: React components, contexts, and hooks are not unit tested, but they must still be covered by an end-to-end test.
   - End each step with: "The code must compile and all tests (unit and smoke/e2e) must pass before marking this step complete."
   - Save the step to its own markdown file at `docs/plans/<plan-name-without-extension>/<N>-<short-slug>.md`, where `<N>` is the 1-based step number and `<short-slug>` is a kebab-case summary of the step (e.g. `2-add-auth-middleware.md`).

4. If the first step was "Write documentation", the **last step** is "Update documentation": revise the documentation written in step 1 to reflect the final state of the code, including anything that changed during implementation. Save it to `docs/plans/<plan-name-without-extension>/<N>-update-documentation.md`. Skip this step when the first step was skipped.

5. Every step file (first, middle, and last) must end with an empty `## Summary` section to be filled in when the step is implemented, recording what was actually done. Format:

```
## Summary

_To be completed when this step is implemented._
```

6. Prepend a numbered implementation steps checklist to the **top** of the original plan file. Format:

```
## Implementation Steps

- [ ] 1. <Step title> — `<plan-name>/<N>-<short-slug>.md`
- [ ] 2. <Step title> — `<plan-name>/<N>-<short-slug>.md`
...
```

Each checkbox lets the user mark the step complete as they work through it.

7. Report back with the list of files created and a one-line summary of each step.

## Next

Recommend the developer run:
- `/plan:imp-next`: implement the first step (write documentation when the plan needs it). After that step, the human reviews and approves the documentation before any later step runs.

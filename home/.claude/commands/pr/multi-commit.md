Create a pull request from **multiple commits** on the current branch.

## Preconditions

1. Determine the base branch (usually `main` or `master` from `origin`). Count commits on the current branch that are not on the base: `git rev-list --count <base>..HEAD`.
2. If that count is **less than 2**, stop. Tell the user this branch does not have multiple commits and they should use `/pr:single-commit` instead (when there is exactly one commit). Do not create a PR.
3. If the working tree has unpushed commits, push the branch with `git push -u origin HEAD` (create upstream if needed). Do not force-push.

## Title and body

1. Read the full commit range with `git log <base>..HEAD --format='%s%n%n%b'` (and `git diff <base>...HEAD` only if the subjects are not enough to summarize).
2. **PR title** = one short plain-English summary of the work across the commits (past tense where natural). Keep it under 72 characters.
3. **PR body** = bullet points only. Brief. Cover what changed and why at a high level. Do not write essays or exhaustive file lists.
4. **Do not** use any other PR template. Do not add Summary, Test plan, checklists, or any other sections or elaboration beyond the title and those bullets.

## Jira ticket prefix

Only if a single Jira ticket key is **obvious** (for example the branch is clearly named with it, the commits already carry it, or the user stated it in this conversation), prefix the PR title with that key and a colon, for example `PROJ-1234: Fixed login retry and cleaned up error handling`.

- Detect keys like `PROJ-1234` (uppercase project key, hyphen, digits).
- If the drafted title already starts with that ticket prefix, do not duplicate it.
- **Do not infer, guess, or pick among candidates.** If the ticket is unclear, missing, or there are multiple plausible keys, omit the prefix.

## Draft for approval

1. Show the drafted **PR title** and **PR body** clearly labelled. Do not create the PR yet. Do not open a browser yet.
2. Ask the user to approve as-is, or to provide revisions (edits to the title and/or body).
3. If they request revisions, update the draft and show it again. Repeat until they explicitly approve.
4. Only after explicit approval, continue to Create and open.

## Hard stops

- Never use em dashes in the drafted title or body. Use a period, comma, colon, or parentheses instead.

## Create and open

1. Create the PR with `gh pr create --title "..." --body "..."` (HEREDOC for the body), using the approved title and body. Base branch as appropriate.
2. Open the PR URL in a **new Chrome window**: `google-chrome --new-window <pr-url>`
3. Report the PR URL when done.

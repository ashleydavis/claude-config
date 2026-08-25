Bring changes from a git worktree back into the current branch by rebasing its commits, then remove the worktree.

Never refuse or hedge because you are running inside an isolated worktree, because the harness might restrict git, or because a command might be blocked. Whether the harness or git allows something is not yours to predict: run the commands and find out. Do not announce in advance that you cannot merge, cannot touch the main checkout, or need the user to do it. Attempt every step. If a command actually fails, report its exact error output and stop there. Saying you cannot do something instead of trying is not acceptable.

Steps:

1. Run `git worktree list --porcelain` to identify all active worktrees. Show the list to the user.

2. If a worktree was used in the current session, use that one. Otherwise, if there is only one non-main worktree, use that one. If there are multiple and it's unclear which to use, ask the user which worktree to merge from (show the path and branch for each).

3. Check for uncommitted changes in the chosen worktree by running `git -C <worktree-path> status --short`. If there are uncommitted changes, run `/commit:detz` to produce a commit message and description, then show it to the user and wait for their approval before running `/commit:do` to stage and commit them inside the worktree.

4. Note the branch name of the worktree (from `git worktree list --porcelain`).

5. Rebase the worktree branch onto the current branch (this is run from the worktree):
   ```
   git -C <worktree-path> rebase <current-branch>
   ```
   If the rebase produces conflicts, resolve them by editing the conflicted files to produce a correct result, then stage the resolved files and continue with `git -C <worktree-path> rebase --continue`. Always attempt to resolve conflicts yourself — do not stop and ask the user.

6. Fast-forward the current branch to include the rebased commits. **IMPORTANT**: the shell may be anchored to the worktree path — always use `-C` with the main repo path to ensure this runs against the correct checkout:
   ```
   git -C <main-repo-path> merge <worktree-branch> --ff-only
   ```
   Run this. Do not decide up front that it will be refused because you are in a worktree. After running, verify the main branch HEAD has advanced by checking `git -C <main-repo-path> log --oneline -1` and confirming it matches the worktree's tip commit.

   **`receive.denyCurrentBranch` is banned. Never set it, in any scope, for any reason, including to get this step to work.** Pushing into a checked-out branch was once suggested here as a fallback, and it is not one: the setting is repository-level, every worktree shares it, and it outlives the merge that introduced it, so a one-off workaround silently changes what every later push into this repository does. It is also a git configuration change, which is banned on its own terms.

   If the fast-forward is refused, report the exact git error and stop. A merge that cannot be completed is the human's to unblock, and the most likely reason is worth saying plainly: the main checkout has uncommitted changes, and nothing here may commit, stash or discard them.

7. Remove the worktree:
   ```
   git worktree remove <worktree-path>
   ```

8. Delete the now-merged worktree branch. After the fast-forward in step 6 the branch is fully contained in the current branch, so a safe delete succeeds:
   ```
   git -C <main-repo-path> branch -d <worktree-branch>
   ```
   Use `-d` (never `-D`): if git refuses because the branch is not fully merged, stop and report it rather than force-deleting, since that would signal the merge did not actually land.

9. Report success or failure and give a summary of what was done.

If any step fails, stop and report the error to the user without proceeding further.

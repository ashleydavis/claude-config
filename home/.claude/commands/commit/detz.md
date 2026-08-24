Produce a commit message and description for the current work.

Gather context in priority order, stopping as soon as you have enough to write a good commit message and description:

1. **Conversation context** - if the current conversation clearly describes what was just done, use that and stop here.
2. **Plan file** - if there is a plan file in the working directory (e.g. plan.md, PLAN.md, or similar), read it. If it describes the completed work well enough, use that and stop here.
3. **Git** - as a last resort, run `git diff --cached`, `git diff`, and `git status` to understand what changed.

Then produce two things:

**Commit message** - one short line, plain English, past tense (e.g. "Added", "Fixed", "Removed", "Updated"), no period at the end. Should convey the intent of the change, not just describe what files changed. Keep it under 72 characters.

**Jira ticket prefix** - only if a single Jira ticket key is **obvious** (for example the branch is clearly named with it, or the user stated it in this conversation). Prefix the commit message with that key and a colon, for example `PROJ-1234: Fixed the flaky login retry`. Detect keys like `PROJ-1234` (uppercase project key, hyphen, digits). If the message already starts with that ticket prefix, do not duplicate it. **Do not infer, guess, or pick among candidates.** If the ticket is unclear, missing, or there are multiple plausible keys, omit the prefix.

**Commit description** - what changed, why, and any decision a later reader could not work out from the diff. There is no length target: write only what the change needs and stop. A one-line change gets a one-line description, and a description that says nothing the subject line did not is omitted entirely. Do not list every file in the commit. This goes in the body of the commit, separated from the subject by a blank line.

Leave out, in every case: anything restating a file that is in the commit (the reader has it), any explanation of how a tool or format works, background on why the general practice is good, and any sentence that would be equally true of some other commit. If a paragraph could be deleted without the reader losing something they needed, delete it.

Describe the change as it stands in this repository, not its history elsewhere. Never mention another repository, project or directory the work came from, and never say a change was copied, moved, ported or brought in from anywhere. Nobody reading this repository's history can see that other place, and it may not exist by the time they read it. The exception is when the human asks for the other repository to be named in that request.

Output all three clearly labelled so the user can review them. Do not commit anything - just produce the text.

**Never put the commit description inside a fenced code block, and never hard-wrap it.** A fenced block is not soft-wrapped by the terminal, so a paragraph written as one long line runs off the right edge and cannot be read. Write the description as ordinary prose in the reply, one long line per paragraph with a blank line between paragraphs, and let the terminal soft-wrap it to whatever width the reader has. The same text goes into the commit unwrapped. The one-line commit message is short enough that a code block is fine for it if you want the user to copy it.

**Files to be committed** - discover all relevant git repos (the current repo plus any others involved in the work), then for each repo run `git diff --cached --name-only` and `git diff --name-only` to get staged and unstaged tracked changes. Group the results by repo, showing the repo root path as a header and listing each file beneath it on its own line. Skip repos with no changes.

When you are done, tell the user they can run `/commit:do` to have Claude stage and commit the changes using these details.

## Next

Recommend the developer run:
- `/commit:do`: stage and commit using the message and description just produced.

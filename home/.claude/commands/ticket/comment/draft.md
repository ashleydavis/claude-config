Draft a Jira ticket comment as a local markdown file for review. Post nothing.

`/ticket:comment:publish` is what posts it. This command writes the file so it can be reviewed and revised first.

## Steps

1. **Resolve the ticket.** Prefer a ticket key or URL from the conversation, branch name, workspace path, or recent commits (for example `PROJ-123`). If it is not obvious, ask the human for a Jira link or key and stop until they provide one. Never invent a key.

2. **Gather what was done.** Prefer conversation context. If that is thin, inspect the ticket workspace and related repos and sub-repos (commits, open PRs, local docs) and summarize from that evidence. Do not invent work. If you cannot tell whether something was finished, say so in the draft rather than claiming it.

3. **Write the draft** to `docs/tickets/<TICKET-KEY>-comment.md`, creating the directory if it does not exist. If a file with that name already exists, read it first: if it is an unpublished draft for the same update, revise it in place rather than starting again. If it was already published, start a new file with a numeric suffix so the earlier comment stays on record.

   Put a short header block at the top with the ticket key, its URL, and a `Status: draft` line. Everything below that is the comment body exactly as it will be posted.

   **Write the body as ordinary markdown. Never wrap it in a code fence.** A fenced body is displayed as source rather than rendered, so the links, headings and bullets the human is meant to be reviewing are unreadable, and editing it means editing inside a block. The header block already marks where the body starts, so nothing needs to fence it off.

   Keep the body concise and Jira ready: what changed, why it matters for this ticket, and links to PRs and docs. Omit secrets, credentials, internal hostnames, account ids, and anything else that does not belong in a ticket comment.

   **Clickable links (required):** Atlassian markdown does not reliably auto-link bare URLs. Every URL must use markdown link form `[label](url)`, for example `[some-repo#28](https://github.com/some-org/some-repo/pull/28)`. Never paste a bare `https://...` URL. Never wrap a URL in backticks, that makes it unclickable.

4. **Report.** Print the file path and the ticket key, and show the body so the human can read it without opening the file. Tell them to revise the file directly if they want changes, and that `/ticket:comment:publish` is what posts it.

## Hard stops

- Never post anything to Jira from this command.
- Never invent a ticket key, a PR link, or work that was not done.
- Never put secrets, credentials, internal hostnames or account ids in the draft.
- Every URL uses `[label](url)`. No bare URLs, no URLs in backticks.
- Never put the comment body in a code fence, in the draft file or when showing it in the reply.

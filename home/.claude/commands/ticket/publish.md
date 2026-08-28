Create a Jira issue from a local ticket draft file.

This is the second half of `/ticket:draft`. It publishes what that produced. It does not write or improve the draft.

**Invoking this command is the approval.** The human has read the draft and asked for it to go on Jira, so do not ask them to confirm again, and do not print the payload back at them. Create it.

The defaults (Story, lowest priority, story points and acceptance criteria present) belong to `/ticket:draft`. This command only enforces them: if the draft breaks one, stop and ask rather than publishing.

## Steps

1. **Find the draft.** Prefer the one produced or discussed in this conversation. Otherwise look in the current ticket working directory for a `*-ticket-draft.md`. If several match, list them and ask which one. Never guess.

2. **Read it in full**, including the Notes section. Anything still marked TBC is a blocker: list every one and ask the human to resolve them before going further. Do not fill them in yourself.

3. **Resolve the target.** Get the `cloudId` (try the site hostname first, fall back to `getAccessibleAtlassianResources`). Take the project key and issue type from the draft's Fields section and call `getJiraProjectIssueTypesMetadata` to confirm that issue type exists in the project.

4. **Map every field.** Call `getJiraIssueTypeMetaWithFields` with `requiredFieldsOnly: false` for that project and issue type. The response is large, so grep the saved tool output rather than reading it whole. Then:

   - Confirm every field the metadata marks required has a value in the draft.
   - Confirm story points and acceptance criteria both have values, whether or not the project marks them required.
   - Check the draft's `customfield_*` ids against the metadata rather than trusting them, and confirm the field the description body is going to is actually on this issue type's screen.
   - Anything without its own parameter on `createJiraIssue` goes in `additional_fields`, keyed by field id or name: priority, labels, components, story points, and every custom field.
   - Resolve the assignee with `lookupJiraAccountId` and use the account id.

5. **Build the description.** Take the draft's body sections in order, and **remove**:

   - the Fields section, it is metadata and now lives in real fields,
   - the Acceptance criteria section, if it is going in its own field,
   - the "Notes for me, not for the ticket" section, always,
   - any remaining TBC markers or internal asides.

   Keep every URL as `[label](url)`. Send it with `contentFormat: "markdown"`.

   If any remaining publishable section still points at a local file that will stay local (working notes, implementation plans, checkouts, `~/…`, `file://`), stop and move that reference into Notes or drop it. A local path is allowed only when it is itself a draft due to be published online. Leave those in the payload only if you will replace them with the live `https://` URL in this same run; otherwise stop and publish the other draft first, or publish this ticket and come back to edit the link.

6. **Create it.** Call `createJiraIssue`, then create any links the Related work section calls for, using `getIssueLinkTypes` first if the link type is not obvious, and set the parent epic if the draft names one. Report the issue key and its browse URL, nothing more.

   A custom field declared as a plain text area may still be rejected unless it is sent as Atlassian Document Format. If the create fails with "not valid Atlassian Document Format (ADF) content", resend that field as an ADF document object rather than a string. Do not drop the field to make the call succeed.

7. **Open it in Chrome.** Run `google-chrome --new-window <browse url>` so the human can check the created issue straight away. The fields that were mapped by id are worth seeing rendered, and a mistake is far easier to fix in the first minute than later.

8. **Record it.** Add the created issue key and URL to the top of the draft file so the local file and the Jira issue stay connected. If any other local draft (this one, or another ticket/doc draft) still links to this file by path, replace that path with the new browse URL. If that other draft is already on Jira, edit the published issue so the reader gets the live link, not the working-directory path.

## When to stop and ask

Only when the answer is not in the draft and picking one would be a guess:

- The draft still contains a TBC.
- A required field has no value in the draft.
- Story points or acceptance criteria are missing.
- The draft names an issue type other than Story without the human having chosen it.
- More than one draft file matches, or the assignee lookup returns more than one person.
- A field value in the draft is not valid for that project, for example a priority name the project does not have. Say what the valid values are and let the human choose.

Everything else proceeds without asking.

## Hard stops

- Never publish a draft that still contains TBC, or the "Notes for me" section, or anything from it.
- Never create an issue without story points and acceptance criteria.
- Never change the issue type yourself, in either direction.
- Never invent a field value, an account id, an epic or a link. Look it up or ask.
- Never guess a `customfield_*` id from memory. Read it from the issue type metadata for that project.
- Never assume the body landed somewhere a reader will see it. Confirm the field is on the issue type's screen.
- Never post bare or backtick-wrapped URLs. Always `[label](url)`.
- Never publish a local file that will stay local. Related work and the description may only link `https://` URLs a reader can open from Jira, except a local draft that is about to be published — and that path must be replaced with the live URL as soon as it exists.

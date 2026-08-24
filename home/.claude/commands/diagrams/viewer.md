---
description: Bootstrap or refresh the diagram viewer page under docs/, rebuilding the diagram menu from the .mmd files that exist in the repo.
argument-hint: [--out docs]
allowed-tools: Read, Glob, Write, Edit, Bash(git remote -v), Bash(git rev-parse --abbrev-ref HEAD), Bash(ls *), Bash(mkdir *), Bash(cp *)
---

Install the diagram viewer into this repository, and rebuild its menu from whatever
`.mmd` files are present.

Run this once to set the page up, and again after diagrams are added, renamed or
deleted. It is idempotent and safe to re-run at any time. It does not read the
codebase and does not write diagrams — that is `/diagrams:create`.

## Arguments

- `--out <dir>` is the docs root. Default `docs`.

## What to write

    <out>/
    ├── .nojekyll             empty file; stops Jekyll processing the directory
    ├── index.html            copied verbatim from the template
    └── diagrams/
        ├── manifest.json     rebuilt from the .mmd files present
        └── *.mmd             left alone

Copy `index.html` from `.claude/commands/diagrams/viewer.html` in this repository, or
from `~/.claude/commands/diagrams/viewer.html` when the command is installed globally
instead. Overwrite any
existing copy so viewer fixes propagate. If that template is missing, stop and say
so rather than writing a page of your own — the template is the artifact under
version control, and a hand-rolled substitute drifts from it on every run. Never
edit `<out>/index.html` in place; change the template and re-run.

Create `<out>/diagrams/` if it does not exist. If it contains no `.mmd` files, say
the page is installed but empty and that `/diagrams:create` fills it.

## Rebuilding the manifest

Glob `<out>/diagrams/*.mmd` and reconcile `manifest.json` against what is actually
on disk. The files are the source of truth; the manifest is an index of them.

For each `.mmd` file:

1. Read its first few lines for the metadata header:

       %% title: Checkout flow
       %% description: What happens between a full cart and a confirmed order.

2. Use `title` as the human-readable name in the menu, and `description` as the line
   under it.
3. If a file has no header, derive a title from the filename — `flow-checkout.mmd`
   becomes "Checkout flow" — and add the header to the file so it names itself next
   time. Say which files you did this to.
4. The diagram id is the filename without its extension.

Then:

- Order `diagrams` so the broadest reading order comes first: context, then modules,
  then flows, then data, then anything else alphabetically. The first entry is what
  a first-time visitor sees.
- Drop entries whose file no longer exists, and list them in your report.
- Add entries for files that were not in the manifest.
- Preserve the `nodes` map untouched. `/diagrams:create` owns it, and it holds
  hand-edited notes. Only remove a node key when no remaining `.mmd` references it,
  and report what you removed.
- Refresh `title` from the repo name, and `repo` from `git remote -v` plus
  `git rev-parse --abbrev-ref HEAD`, converting an SSH remote to its https form.
  Omit `repo` if there is no remote.

## Report back

The diagrams now in the menu and their order, any file you added a header to, any
manifest entry you dropped, and:

    cd <out> && python3 -m http.server 8000     # then open http://localhost:8000/

Then the Pages setup, once per repository: Settings → Pages → Source "Deploy from a
branch", branch `main`, folder `/docs`.

Mention, if this is the first run, that the viewer fetches the `.mmd` files over HTTP
rather than embedding them — so the diagrams stay the single source of truth and can
be hand-edited without regenerating the page, but opening `index.html` straight from
disk shows a "serve this folder" message instead of a diagram. The page itself
explains this when it happens.

Do not claim the page works in a browser unless you actually loaded it.

---
description: Read a codebase, or one part of it, and write a Mermaid architecture diagram under docs/diagrams/ with a manifest entry describing each node.
argument-hint: [path ...] [--id <name>] [--kind context|modules|flow|data] [--out docs]
allowed-tools: AskUserQuestion, Read, Glob, Grep, Write, Edit, Bash(git remote -v), Bash(git rev-parse --abbrev-ref HEAD), Bash(ls *), Bash(mkdir *)
---

Read the code under `$ARGUMENTS` and write a Mermaid diagram of it. With no path
given, ask what to diagram before reading anything.

This command writes diagrams only. `/diagrams:viewer` builds the page that displays
them; run it once per repository, and again after adding a diagram.

## Ask first when no path is given

A path on the command line answers this question, so skip it. Otherwise ask, and wait
for the answer before opening a single file. Do not assume the current repository is
the target — it may be a tool whose own code nobody wants drawn.

    What do you want to diagram?
    1. The code/app/library in this repo.
    2. A subsystem in this repo.
    3. Somewhere else.

- **1** — survey the whole repository, exactly as if the repo root had been given as
  the path.
- **2** — ask which subsystem, then use that answer as the path argument.
- **3** — ask where, and read that instead. Written diagrams still land under
  `<out>/diagrams/` in the current repository unless the answer says otherwise.

## Arguments

- Bare paths scope the survey. `src/api src/workers` means read those trees and
  diagram what is inside them, treating anything outside as an external edge.
- `--id <name>` sets the diagram id, which becomes the filename and the URL hash.
  Default: derive it from the kind and scope, for example `flow-checkout`,
  `modules-api`.
- `--kind` picks what question the diagram answers. Default: choose it yourself.
- `--out <dir>` is the docs root. Default `docs`. Diagrams go in `<out>/diagrams/`.

Write one diagram per invocation unless the survey clearly needs several, in which
case say so up front, list what you intend to write, and write them all.

## Choosing what to draw

A diagram answers one question. Prefer several small ones over one map of everything.

- `context` — the system, its users, and the external services it talks to. One box
  for the system itself.
- `modules` — internal components and their dependencies: services, packages,
  workspace members, deployable units.
- `flow` — one runtime path end to end, named for what it does. The best value for a
  newcomer, and the one most worth spending effort on.
- `data` — stores, queues, and which components read and write each.

If the result would have fewer than four nodes, it is not a diagram. Widen the scope
or fold it into an existing one.

## Surveying

Work from evidence in the repository, never from what a project of this kind usually
looks like.

1. Read the manifests first: `package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`,
   `pom.xml`, `*.csproj`, `docker-compose.yml`, Terraform, Helm charts, CI workflows.
   Workspace and compose files hand you the real component boundaries.
2. Map the directory structure onto those components, then confirm each by reading
   its entry point.
3. Trace edges from imports, HTTP and RPC clients, queue publish and subscribe calls,
   database clients, and environment variable names. An edge goes in only when you
   have read the line that creates it.
4. Skip `node_modules`, `vendor`, `dist`, `build`, `target`, `.git`, lock files,
   generated clients, and fixtures. Read test files for how things wire together, but
   do not draw them as components.

Too large to read exhaustively? Sample deliberately — every manifest, every entry
point, then the files that imports point at most often — and say in your report what
you sampled rather than read.

## Writing the diagram

`<out>/diagrams/<id>.mmd`, starting with a metadata header:

    %% title: Checkout flow
    %% description: What happens between a full cart and a confirmed order.

    flowchart TB
    ...

Those two comment lines are how the diagram names itself. Mermaid ignores `%%` lines,
and `/diagrams:viewer` reads them to build the menu, so a diagram added by hand shows
up with a proper name and no manifest editing. `title` is a short human name for the
menu; `description` is one line on what question the diagram answers.

Then:

- `flowchart TB`, or `LR` when the graph is wide and shallow.
- Node ids are stable, lowercase, prefixed by area: `api_gateway`, `db_orders`. They
  must survive a re-run so links and manifest entries stay valid.
- Never use a Mermaid keyword as an id: `end`, `graph`, `subgraph`, `class`, `click`,
  `style`, `linkStyle`, `o`, `x`.
- Shapes carry meaning: `["service"]`, `[("datastore")]`, `[["queue or topic"]]`,
  `(["external or actor"])`.
- Group with `subgraph` by deployable or bounded context, not folder depth.
- Label an edge only when the label says something the arrow does not: an event name,
  a protocol, a trigger. Unlabelled is the default.
- No `click` directives, no `style` or `classDef`. The viewer supplies interaction
  and theme, and inline styling fights it.

Before writing, check the file yourself: every id used in an edge is defined, no id
defined twice, no reserved words, every `subgraph` has a matching `end`. A typo'd id
does not error in Mermaid — it silently creates a phantom node, which is the failure
nobody catches by eye.

## Updating the manifest

Add or update this diagram's entry in `<out>/diagrams/manifest.json`, creating the
file if it does not exist. Leave every other entry alone.

    {
      "title": "<repo name>",
      "repo": "https://github.com/<owner>/<repo>/blob/<default-branch>",
      "diagrams": [
        { "id": "flow-checkout", "title": "Checkout flow", "file": "flow-checkout.mmd",
          "description": "What happens between a full cart and a confirmed order.",
          "generated": "<ISO date>" }
      ],
      "nodes": {
        "api_gateway": {
          "label": "API gateway",
          "kind": "Service",
          "path": "src/gateway",
          "note": "One or two sentences: what it owns, what it talks to."
        }
      }
    }

`title` and `description` on the entry must match the `%%` header in the `.mmd`.

Get `repo` from `git remote -v` and the branch from `git rev-parse --abbrev-ref HEAD`,
converting an SSH remote to its https form. Omit the key if there is no remote; the
viewer then shows the path as plain text instead of a link.

`nodes` is keyed by Mermaid node id and shared across every diagram, so a node used
in two diagrams is described once. Every node you draw needs an entry, and every
`path` must be a real file or directory relative to the repo root. This is what turns
the page from a picture into something navigable: clicking a node opens the code.

Keep hand-edited `note` text on nodes that still exist. A note someone wrote by hand
is better than one you generate; only replace it when the component's job has
actually changed, and say so when you do.

## Report back

Node and edge count, which paths you sampled rather than read in full, anything you
could not resolve (dynamic dispatch, config-driven wiring, a service whose caller you
never found), and any node that disappeared since the last run — a vanished node is
either a deletion worth knowing about or a survey that missed something.

If `<out>/index.html` does not exist yet, say that `/diagrams:viewer` needs to run
before the diagram can be viewed as a page.

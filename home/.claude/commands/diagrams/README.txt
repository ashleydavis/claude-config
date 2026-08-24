diagrams

Architecture diagrams generated from a codebase, published as a web page.

The output is a folder GitHub Pages can serve directly:

    docs/
    |-- .nojekyll
    |-- index.html            the viewer, copied from viewer.html in this directory
    `-- diagrams/
        |-- manifest.json     diagram menu, plus one entry per node
        `-- *.mmd             one Mermaid file per diagram

The diagrams are plain .mmd files and the viewer fetches them at runtime, so the
Mermaid stays the single source of truth. Nothing is duplicated into the HTML, and
a diagram can be edited by hand without regenerating the page.

This file is plain text, not markdown, because Claude Code registers every .md file
under commands/ as a slash command, and a readme is documentation rather than
something to run. viewer.html sits here beside the commands because it is the
versioned template, and the commands copy it rather than writing their own.

The commands

  /diagrams:create    Reads the repository, or the paths given as arguments, and
                      writes one diagram plus the manifest entries describing its
                      nodes. Takes optional paths to scope the survey, --id to name
                      the diagram, --kind to pick context/modules/flow/data, and
                      --out for the docs root. Run it once per diagram.

  /diagrams:viewer    Installs or refreshes the viewer page, and rebuilds the menu
                      from whatever .mmd files exist. Does not read the codebase.
                      Run it once to set up, and again after diagrams are added,
                      renamed or deleted.

Two commands rather than one because they change at different rates. Diagrams are
written a few at a time as the survey proceeds; the page is installed once and then
only refreshed when the template improves. Splitting them also means a diagram
written by hand, with no survey involved, still shows up in the menu.

How a diagram names itself

Each .mmd starts with a metadata header:

    %% title: Checkout flow
    %% description: What happens between a full cart and a confirmed order.

    flowchart TB
    ...

Mermaid ignores %% lines. /diagrams:viewer reads them to build the menu, so a file
dropped into docs/diagrams/ by hand appears with a proper human-readable name after
a refresh, with no manifest editing. A file with no header gets a title derived from
its filename, and the header written back into it.

The viewer

Pan by dragging, zoom by scrolling or double-clicking, fit with 0, fullscreen with F.
The diagram menu lists every .mmd by its human name. Clicking a node shows its
description from the manifest and links to the source directory on GitHub.

State is kept in localStorage, keyed by the page's path so several repos can share
one github.io origin without colliding: the diagram you had open, and the zoom and
pan position of each diagram separately. Re-opening the page puts you back exactly
where you were. A URL hash overrides the remembered diagram, so a link to one
diagram still works. Pan and zoom writes are debounced, and everything is wrapped in
try/catch so Safari private mode degrades to no persistence rather than breaking.

Mermaid and the pan/zoom library load from jsDelivr, so the page needs a network
connection but no build step and no dependencies in the project itself.

Two things the viewer works around, both documented upstream. Mermaid caps its SVG
with an inline max-width, which stops the diagram filling its container
(mermaid-js/mermaid#5038), so the viewer strips it and lets the viewBox handle the
initial fit. And everything is wrapped in a single <g> before the pan/zoom library
attaches, which is the fix the svg-pan-zoom readme gives for slow first paints on
large diagrams; it applies equally to anvaka/panzoom, which is what this uses.

Serving it

A page opened straight from disk cannot fetch its sibling .mmd files: browsers treat
each local file as its own origin. Locally, serve the folder instead:

    cd docs && python3 -m http.server 8000

On GitHub Pages it works with no extra steps. Settings -> Pages -> Source: "Deploy
from a branch", branch main, folder /docs. The .nojekyll file stops Jekyll from
processing the directory.

If you only want to look at one diagram, the Open .mmd button and drag-and-drop both
work from disk with no server. An ad-hoc file loaded that way has no saved view.

Limits

Layout is Mermaid's, which is dagre, and it is single-threaded: a diagram past
roughly a hundred nodes locks the tab for a moment while it renders. That cost is
paid once on load, and panning stays smooth afterwards because the whole diagram is
one transformed group. If a generated diagram is that big it usually means the
survey should have produced several smaller diagrams instead of one map of
everything, which is what /diagrams:create is told to prefer.

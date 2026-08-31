#!/bin/bash

# Agent Config Bootstrap
# Symlinks Claude and Cursor configuration into ~/.claude and ~/.cursor using
# GNU Stow, while keeping each tool's runtime state OUT of this repo.
#
# Slash commands and personal skills do not live in this repo. They moved to
# agent-skills (~/skills/agent-skills) and are installed with skl. This script
# never stows home/.claude/commands, home/.cursor/commands, or a skills tree,
# and it removes leftover links from earlier installs that still point here.
#
# Why this is not just "stow home":
# The stow package contains home/.claude and home/.cursor. If ~/.claude or
# ~/.cursor does not already exist, stow "folds" the tree and makes that path a
# single symlink pointing into this repo. The tool then writes ALL of its runtime
# state through that symlink, dumping it into the repo working tree. To prevent
# that we ensure each target is a REAL directory first, so stow only links the
# individual config files/dirs and runtime state stays in the real home dirs.
#
# Usage: ./bootstrap.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v stow &> /dev/null; then
    echo "ERROR: GNU Stow is not installed." >&2
    echo "Install it with: sudo apt install stow   (or: brew install stow)" >&2
    exit 1
fi

# Slash commands and personal skills moved to agent-skills. Never treat them as
# config this package still ships (git may still list deleted files until that
# deletion is committed). permissions.d/commands is unrelated: those are
# permission-parser descriptors, not slash commands.
is_migrated_skill_entry() {
    [[ "$1" == "commands" || "$1" == "skills" ]]
}

# Top-level names this package still installs under home/.claude or home/.cursor.
package_entries() {
    local git_prefix="$1"
    git -C "$SCRIPT_DIR" ls-files "$git_prefix" \
        | awk -F/ 'NF>=3 && $3 != "commands" && $3 != "skills" {print $3}' \
        | sort -u
}

# Un-fold a target dir if it is a single symlink into this package, then ensure
# it exists as a real directory before stow.
unfold_if_needed() {
    local tool_name="$1"   # e.g. claude
    local home_target="$2" # e.g. $HOME/.claude
    local pkg_dir="$3"     # e.g. $SCRIPT_DIR/home/.claude
    local git_prefix="$4"  # e.g. home/.claude

    if [[ ! -d "$pkg_dir" ]]; then
        echo "ERROR: Expected directory not found: $pkg_dir" >&2
        exit 1
    fi

    if [[ -L "$home_target" ]]; then
        echo "Detected folded $home_target symlink; un-folding..."

        mapfile -t KEEP < <(package_entries "$git_prefix")
        if [[ ${#KEEP[@]} -eq 0 ]]; then
            echo "ERROR: could not determine tracked config entries for $tool_name; aborting so we" >&2
            echo "       don't accidentally move config out of the repo." >&2
            exit 1
        fi

        rm "$home_target"
        mkdir -p "$home_target"

        shopt -s dotglob nullglob
        for path in "$pkg_dir"/*; do
            name="$(basename "$path")"
            if is_migrated_skill_entry "$name"; then
                echo "  skipping $name (skills/commands live in agent-skills, not this repo)"
                continue
            fi
            keep=false
            for k in "${KEEP[@]}"; do
                [[ "$name" == "$k" ]] && { keep=true; break; }
            done
            if ! $keep; then
                echo "  evicting runtime state from repo -> $home_target/: $name"
                mv "$path" "$home_target/"
            fi
        done
        shopt -u dotglob nullglob
    fi

    mkdir -p "$home_target"
}

# Remove package-entry symlinks that point outside this repo. --adopt only
# handles plain files; leftovers from a previous install path (e.g. the repo
# was renamed from claude-config -> agent-config) are "not owned by stow" and
# abort the whole run. Runtime dirs/files that are not package entries are
# left alone.
clear_foreign_package_symlinks() {
    local home_subdir="$1" # e.g. .claude
    local git_prefix="$2"  # e.g. home/.claude

    mapfile -t ENTRIES < <(package_entries "$git_prefix")
    if [[ ${#ENTRIES[@]} -eq 0 ]]; then
        return 0
    fi

    for name in "${ENTRIES[@]}"; do
        local dest="$HOME/$home_subdir/$name"
        [[ -L "$dest" ]] || continue

        local resolved
        resolved="$(realpath -m "$dest")"
        if [[ "$resolved" != "$SCRIPT_DIR"/* ]]; then
            echo "  removing stale symlink $dest (-> $(readlink "$dest"))"
            rm "$dest"
        fi
    done
}

# Remove leftover slash-command and personal-skill links this repo used to stow.
# Only delete symlinks that resolve into this repo. skl-managed links (me, ark,
# pla, and anything else under ~/.skilled) point elsewhere and stay.
remove_legacy_skill_links() {
    local dest_dir="$1"

    if [[ -L "$dest_dir" ]]; then
        local resolved
        resolved="$(realpath -m "$dest_dir")"
        if [[ "$resolved" == "$SCRIPT_DIR"/* ]]; then
            echo "  removing leftover $dest_dir (-> $(readlink "$dest_dir"))"
            rm "$dest_dir"
        fi
        return 0
    fi

    [[ -d "$dest_dir" ]] || return 0

    local path resolved
    shopt -s nullglob
    for path in "$dest_dir"/*; do
        [[ -L "$path" ]] || continue
        resolved="$(realpath -m "$path")"
        if [[ "$resolved" == "$SCRIPT_DIR"/* ]]; then
            echo "  removing leftover $path (-> $(readlink "$path"))"
            rm "$path"
        fi
    done
    shopt -u nullglob
}

unfold_if_needed "claude" "$HOME/.claude" "$SCRIPT_DIR/home/.claude" "home/.claude"
unfold_if_needed "cursor" "$HOME/.cursor" "$SCRIPT_DIR/home/.cursor" "home/.cursor"

echo "Clearing stale package symlinks (if any) ..."
clear_foreign_package_symlinks ".claude" "home/.claude"
clear_foreign_package_symlinks ".cursor" "home/.cursor"

echo "Removing leftover skill/command links from this repo (if any) ..."
remove_legacy_skill_links "$HOME/.claude/commands"
remove_legacy_skill_links "$HOME/.cursor/commands"
remove_legacy_skill_links "$HOME/.claude/skills"
remove_legacy_skill_links "$HOME/.cursor/skills"

echo "Stowing $SCRIPT_DIR/home into $HOME ..."
cd "$SCRIPT_DIR"
# --adopt resolves conflicts where a config target already exists as a real file
# (e.g. a tool rewrote settings.json or AGENTS.md in place, replacing the symlink):
# stow moves the live file's content into the repo and recreates the symlink, so
# nothing is lost. Review/keep/discard the adopted content afterwards with git.
# home/.stow-local-ignore keeps commands/ and skills/ out of the stow even if
# those trees reappear in the package.
stow --adopt --target="$HOME" home

echo "Done."
echo "Config files are symlinked from this repo; runtime state lives in the real"
echo "~/.claude and ~/.cursor and is never written into the repo."
echo "Slash commands and personal skills are not installed from this repo."
echo "Install them from agent-skills with: skl -g add ashleydavis/agent-skills --ns me"

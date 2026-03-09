#!/bin/sh
# install.sh — symlink skills into Claude Code
# POSIX sh compatible, no bashisms

set -e

# --- Colors (disabled if not a terminal) ---
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    RED='\033[0;31m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    GREEN=''
    YELLOW=''
    RED=''
    BOLD=''
    RESET=''
fi

SKILLS_DIR="$HOME/.claude/skills"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_PREFIX=""

info()  { printf "${GREEN}[+]${RESET} %s\n" "$1"; }
warn()  { printf "${YELLOW}[!]${RESET} %s\n" "$1"; }
error() { printf "${RED}[-]${RESET} %s\n" "$1"; }

# --- Uninstall ---
do_uninstall() {
    info "Uninstalling skills..."
    removed=0
    for target in "$SKILLS_DIR/${SKILL_PREFIX}"*; do
        [ -e "$target" ] || continue
        if [ -L "$target" ]; then
            link_dest="$(readlink "$target")"
            case "$link_dest" in
                "$REPO_DIR"/skills/*)
                    rm "$target"
                    info "Removed symlink: $(basename "$target")"
                    removed=$((removed + 1))
                    ;;
                *)
                    warn "Skipping $(basename "$target") — symlink points elsewhere"
                    ;;
            esac
        else
            warn "Skipping $(basename "$target") — not a symlink"
        fi
    done
    if [ "$removed" -eq 0 ]; then
        warn "No skill symlinks found to remove"
    else
        info "Removed $removed skill(s)"
    fi
    exit 0
}

# --- Parse flags ---
case "${1:-}" in
    --uninstall) do_uninstall ;;
    --help|-h)
        printf "Usage: %s [--uninstall]\n" "$0"
        printf "  Install:   %s\n" "$0"
        printf "  Uninstall: %s --uninstall\n" "$0"
        exit 0
        ;;
    "")  ;; # install
    *)
        error "Unknown option: $1"
        printf "Usage: %s [--uninstall]\n" "$0"
        exit 1
        ;;
esac

# --- Install ---
info "Installing skills for Claude Code..."

# Create skills directory if needed
if [ ! -d "$SKILLS_DIR" ]; then
    mkdir -p "$SKILLS_DIR"
    info "Created $SKILLS_DIR"
fi

installed=0
skipped=0

for skill_dir in "$REPO_DIR/skills/${SKILL_PREFIX}"*; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    target="$SKILLS_DIR/$skill_name"

    if [ -e "$target" ]; then
        if [ -L "$target" ] && [ "$(readlink "$target")" = "$skill_dir" ]; then
            warn "$skill_name — already linked (skipping)"
        else
            warn "$skill_name — already exists at target (skipping, won't overwrite)"
        fi
        skipped=$((skipped + 1))
        continue
    fi

    ln -s "$skill_dir" "$target"
    info "$skill_name — installed"
    installed=$((installed + 1))
done

printf "\n"
info "${BOLD}Done!${RESET} Installed: $installed, Skipped: $skipped"
info "Skills are now available in Claude Code."

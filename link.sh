#!/usr/bin/env bash
# ╭─────────────────────────────────────────────╮
# │  link.sh — Dotfiles Symlinking Script       │
# │  Deploys configs safely with auto-backups   │
# ╰─────────────────────────────────────────────╯
set -euo pipefail

# ANSI color codes for premium logging
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly RESET='\033[0m'

info()    { printf "${BLUE}[INFO]${RESET} %s\n" "$*"; }
warn()    { printf "${YELLOW}[WARN]${RESET} %s\n" "$*"; }
success() { printf "${GREEN}[SUCCESS]${RESET} %s\n" "$*"; }
error()   { printf "${RED}[ERROR]${RESET} %s\n" "$*" >&2; }

die() {
    error "$*"
    exit 1
}

trap 'die "An unexpected error occurred during symlinking at line $LINENO"' ERR

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Ensure config directories exist
mkdir -p "$HOME/.config"

# Helper function to safely symlink configurations with automatic backup
safe_link() {
    local source_path="$1"
    local target_path="$2"

    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        # If it is already a symlink pointing to the correct place, do nothing
        if [ -L "$target_path" ] && [ "$(readlink -f "$target_path")" = "$(readlink -f "$source_path")" ]; then
            info "Link already exists and is correct: $target_path -> $source_path"
            return
        fi

        # Backup existing target
        mkdir -p "$BACKUP_DIR"
        warn "Backing up existing: $target_path -> $BACKUP_DIR/$(basename "$target_path")"
        mv "$target_path" "$BACKUP_DIR/"
    fi

    info "Creating symlink: $target_path -> $source_path"
    ln -sfn "$source_path" "$target_path"
}

main() {
    info "Starting dotfiles symlinking process..."

    # Symlink configurations inside ~/.config
    safe_link "$CONFIG_DIR/hypr" "$HOME/.config/hypr"
    safe_link "$CONFIG_DIR/waybar" "$HOME/.config/waybar"
    safe_link "$CONFIG_DIR/mako" "$HOME/.config/mako"
    safe_link "$CONFIG_DIR/ghostty" "$HOME/.config/ghostty"
    safe_link "$CONFIG_DIR/rofi" "$HOME/.config/rofi"
    safe_link "$CONFIG_DIR/tmux" "$HOME/.config/tmux"
    safe_link "$CONFIG_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

    # Symlink shell profile configurations
    safe_link "$CONFIG_DIR/zsh/zshrc" "$HOME/.zshrc"

    success "All dotfiles linked successfully!"
    if [ -d "$BACKUP_DIR" ]; then
        info "Pre-existing configurations backed up to: $BACKUP_DIR"
    fi
}

main "$@"

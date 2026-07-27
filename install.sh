#!/usr/bin/env bash
# ╭─────────────────────────────────────────────╮
# │  install.sh — Master Installation Script    │
# │  Updates system, installs packages & fonts, │
# │  configures PAM and links all dotfiles      │
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

trap 'die "An unexpected error occurred during installation at line $LINENO"' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utility functions & package lists
source "$SCRIPT_DIR/packages.sh"

main() {
    info "Updating system package database..."
    sudo apt update
    sudo apt full-upgrade -y

    # Install packages and third-party setups
    install_packages
    install_ghostty
    install_starship
    install_fonts

    # System and service configuration
    configure_services
    configure_pam_hyprlock

    # Symlink configurations using the deployment script
    info "Deploying configurations and symlinks..."
    bash "$SCRIPT_DIR/link.sh"

    success "Master installation and configuration completed successfully!"
}

main "$@"

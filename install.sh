#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Debian Trixie + Hyprland workstation bootstrap
# ============================================================

readonly RED='\033[0;31m'
readonly BLUE='\033[1;34m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RESET='\033[0m'

success() { printf "${GREEN}[SUCCESS]${RESET} %s\n" "$*"; }
info()    { printf "${BLUE}[INFO]${RESET} %s\n" "$*"; }
warn()    { printf "${YELLOW}[WARN]${RESET} %s\n" "$*"; }
die() {
    printf "${RED}[ERROR]${RESET} %s\n" "$*" >&2
    exit 1
}

trap 'die "Failed on line $LINENO"' ERR

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_USER="$(whoami)"

# ============================================================
# Sanity checks
# ============================================================

if [[ "$EUID" -eq 0 ]]; then
    die "Do not run this script as root. Run it as your normal user."
fi

if ! grep -qi '^ID=debian' /etc/os-release; then
    die "This script is intended for Debian."
fi

if ! grep -qi 'trixie' /etc/os-release; then
    warn "/etc/os-release does not mention Debian Trixie."
    read -rp "Continue anyway? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || exit 1
fi

# ============================================================
# APT
# ============================================================

info "Updating APT..."
sudo apt update

info "Installing base APT tooling..."
sudo apt install -y \
    ca-certificates \
    curl \
    wget \
    gnupg \
    apt-transport-https

# Debian Trixie uses deb822 .sources files.
# Keep backports isolated instead of modifying Debian's main sources.
info "Enabling Trixie backports..."

sudo tee /etc/apt/sources.list.d/trixie-backports.sources >/dev/null <<'EOF'
Types: deb
URIs: http://deb.debian.org/debian
Suites: trixie-backports
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

sudo apt update

success "APT sources ready"

# ============================================================
# Base development / CLI tooling
# ============================================================

info "Installing base development and CLI tooling..."

sudo apt install -y \
    build-essential \
    cmake \
    pkg-config \
    git \
    unzip \
    zip \
    file \
    xdg-user-dirs \
    xdg-utils \
    zsh \
    tmux \
    ripgrep \
    btop \
    fastfetch \
    fd-find \
    fzf \
    jq \
    tree \
    curl \
    wget

success "Base tooling installed"

# ============================================================
# Wayland / Hyprland
# ============================================================

info "Installing Hyprland and Wayland ecosystem..."

sudo apt install -y \
    waybar \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    rofi \
    thunar \
    mako-notifier \
    wl-clipboard \
    polkitd \
    hyprpolkitagent \
    slurp \
    grim \
    brightnessctl \
    playerctl \
    hyprpaper \
    hypridle \
    hyprlock

# Hyprland is kept on backports.
sudo apt install -y -t trixie-backports hyprland
success "Hyprland + Wayland ecosystem installed"

# ============================================================
# Audio
# ============================================================

info "Setting up PipeWire audio..."

sudo apt install -y \
    pipewire \
    pipewire-audio \
    pipewire-pulse \
    wireplumber \
    libspa-0.2-bluetooth

systemctl --user enable --now \
    pipewire \
    pipewire-pulse \
    wireplumber \
    2>/dev/null || true

success "PipeWire audio ready"

# ============================================================
# NetworkManager
# ============================================================

info "Enabling NetworkManager..."

sudo apt install -y network-manager
sudo systemctl enable --now NetworkManager

success "NetworkManager enabled"

# ============================================================
# SDDM
# ============================================================

info "Installing SDDM login manager..."

sudo apt install -y sddm
sudo systemctl enable sddm

success "SDDM installed and enabled"

# ============================================================
# Fonts
# ============================================================

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

info "Installing JetBrains Mono Nerd Font..."

if [[ ! -d "$FONT_DIR/JetBrainsMono" ]]; then
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT

    curl -fL -o "$TMP_DIR/jbm.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

    mkdir -p "$FONT_DIR/JetBrainsMono"
    unzip -oq "$TMP_DIR/jbm.zip" -d "$FONT_DIR/JetBrainsMono"

    rm -rf "$TMP_DIR"
    fc-cache -f "$FONT_DIR"
else
    info "JetBrains Mono Nerd Font already installed"
fi

success "JetBrains Mono Nerd Font ready"

info "Installing FiraCode Nerd Font..."

if [[ ! -d "$FONT_DIR/FiraCode" ]]; then
    TMP_DIR="$(mktemp -d)"

    curl -fL -o "$TMP_DIR/fira.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"

    mkdir -p "$FONT_DIR/FiraCode"
    unzip -oq "$TMP_DIR/fira.zip" -d "$FONT_DIR/FiraCode"

    rm -rf "$TMP_DIR"
    fc-cache -f "$FONT_DIR"
else
    info "FiraCode Nerd Font already installed"
fi

success "FiraCode Nerd Font ready"

# ============================================================
# Ghostty
# ============================================================

info "Installing Ghostty..."

if ! command -v ghostty >/dev/null 2>&1; then
    TMP_DIR="$(mktemp -d)"

    curl -fL -o "$TMP_DIR/ghostty.deb" \
        "https://github.com/dariogriffo/ghostty-debian/releases/download/1.3.1%2B5/ghostty_1.3.1-5.trixie_amd64.deb"

    sudo apt install -y "$TMP_DIR/ghostty.deb"

    rm -rf "$TMP_DIR"
else
    info "Ghostty already installed"
fi

success "Ghostty installed"

# ============================================================
# Zsh + Oh My Zsh
# ============================================================

info "Setting up Zsh + Oh My Zsh..."

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no \
    CHSH=no \
    KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    info "Oh My Zsh already installed"
fi

# ============================================================
# Rust
# ============================================================

info "Installing Rust via rustup..."

if ! command -v rustc >/dev/null 2>&1; then
    curl --proto '=https' \
         --tlsv1.2 \
         -sSf https://sh.rustup.rs \
         | sh -s -- -y --no-modify-path
fi

# Make cargo/rustc available in this script immediately.
source "$HOME/.cargo/env"

success "Rust installed: $(rustc --version)"

# ============================================================
# Yazi
# ============================================================

info "Installing Yazi..."

if ! command -v yazi >/dev/null 2>&1; then
    cargo install --force yazi-build
else
    info "Yazi already installed"
fi

success "Yazi installed: $(yazi --version 2>/dev/null || echo 'restart shell if needed')"

# ============================================================
# Zed
# ============================================================

info "Installing Zed..."

if ! command -v zed >/dev/null 2>&1; then
    curl -f https://zed.dev/install.sh | sh
else
    info "Zed already installed"
fi

success "Zed installed"

# ============================================================
# Flatpak + Zen Browser
# ============================================================

info "Installing Flatpak..."

sudo apt install -y flatpak

if ! flatpak remotes | grep -q '^flathub'; then
    flatpak remote-add --if-not-exists \
        flathub \
        https://flathub.org/repo/flathub.flatpakrepo
fi

info "Installing Zen Browser..."

if ! flatpak info app.zen_browser.zen >/dev/null 2>&1; then
    flatpak install -y --noninteractive \
        flathub \
        app.zen_browser.zen
else
    info "Zen Browser already installed"
fi

success "Zen Browser installed"

# ============================================================
# User directories
# ============================================================

xdg-user-dirs-update || true

# ============================================================
# Final
# ============================================================

success "============================================================"
success "Debian workstation setup complete!"
success "============================================================"

info "You should reboot before starting your Hyprland session."

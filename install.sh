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
# Neovim (build from source; Debian only ships 0.10)
# ============================================================

info "Building Neovim from source..."

if command -v nvim >/dev/null 2>&1 && ! nvim --version | head -1 | grep -q '^NVIM v0\.10'; then
    info "Neovim already installed: $(nvim --version | head -1)"
else
    TMP_DIR="$(mktemp -d)"

    git clone https://github.com/neovim/neovim "$TMP_DIR/neovim"
    git -C "$TMP_DIR/neovim" checkout stable

    make -C "$TMP_DIR/neovim" CMAKE_BUILD_TYPE=RelWithDebInfo
    sudo make -C "$TMP_DIR/neovim" install

    rm -rf "$TMP_DIR"

    success "Neovim installed: $(nvim --version | head -1)"
fi

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
# THEMES
# ============================================================

info "Setting up themes..."
sudo apt install arc-theme
success "Arc theme installed"

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

    success "JetBrains Mono Nerd Font ready"
else
    info "JetBrains Mono Nerd Font already installed"
fi

info "Installing FiraCode Nerd Font..."

if [[ ! -d "$FONT_DIR/FiraCode" ]]; then
    TMP_DIR="$(mktemp -d)"

    curl -fL -o "$TMP_DIR/fira.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"

    mkdir -p "$FONT_DIR/FiraCode"
    unzip -oq "$TMP_DIR/fira.zip" -d "$FONT_DIR/FiraCode"

    rm -rf "$TMP_DIR"
    fc-cache -f "$FONT_DIR"

    success "FiraCode Nerd Font ready"
else
    info "FiraCode Nerd Font already installed"
fi

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

    success "Ghostty installed"
else
    info "Ghostty already installed"
fi

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

if command -v rustc >/dev/null 2>&1; then
    info "Rust already installed: $(rustc --version)"
else
    curl --proto '=https' \
         --tlsv1.2 \
         -sSf https://sh.rustup.rs \
         | sh -s -- -y --no-modify-path

    # Make cargo/rustc available in this script immediately.
    source "$HOME/.cargo/env"

    success "Rust installed: $(rustc --version)"
fi

# ============================================================
# Node.js (via nvm) + pnpm
# ============================================================

info "Installing Node.js via nvm..."

if [[ ! -s "$HOME/.nvm/nvm.sh" ]]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.6/install.sh | bash
fi

# In lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"

nvm install 24

success "Node.js installed: $(node -v)"

info "Installing pnpm..."

corepack enable pnpm

success "pnpm installed: $(pnpm -v)"

# ============================================================
# OpenCode
# ============================================================

info "Installing OpenCode..."

if ! command -v opencode >/dev/null 2>&1; then
    curl -fsSL https://opencode.ai/install | bash
    success "OpenCode installed"
else
    info "OpenCode already installed"
fi

# ============================================================
# Yazi
# ============================================================

info "Installing Yazi..."

if ! command -v yazi >/dev/null 2>&1; then
    cargo install --force yazi-build
    success "Yazi installed: $(yazi --version 2>/dev/null || echo 'restart shell if needed')"
else
    info "Yazi already installed"
fi

# ============================================================
# Zed
# ============================================================

info "Installing Zed..."

if ! command -v zed >/dev/null 2>&1; then
    curl -f https://zed.dev/install.sh | sh
    success "Zed installed"
else
    info "Zed already installed"
fi

# ============================================================
# GitHub CLI (gh)
# ============================================================

info "Installing GitHub CLI..."

if ! command -v gh >/dev/null 2>&1; then
    sudo mkdir -p -m 755 /etc/apt/keyrings

    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

    sudo apt update
    sudo apt install -y gh
    success "GitHub CLI installed: $(gh --version 2>/dev/null | head -1)"
else
    info "GitHub CLI already installed"
fi

# ============================================================
# Hugging Face CLI (hf)
# ============================================================

info "Installing Hugging Face CLI..."

if ! command -v hf >/dev/null 2>&1; then
    curl -LsSf https://hf.co/cli/install.sh | bash
    success "Hugging Face CLI installed: $(hf --version 2>/dev/null || echo 'restart shell if needed')"
else
    info "Hugging Face CLI already installed"
fi

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
    success "Zen Browser installed"
else
    info "Zen Browser already installed"
fi

# ============================================================
# Jetbrains toolbox
# ============================================================

info "Installing JetBrains Toolbox..."

INSTALL_DIR="/opt/jetbrains-toolbox"

if [[ ! -x "$INSTALL_DIR/jetbrains-toolbox" ]]; then
    TEMP_DIR="$(mktemp -d)"

    RELEASES_API='https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release'
    JSON="$(curl -fsSL "$RELEASES_API")"

    TOOLBOX_URL="$(echo "$JSON" | jq -r '.TBA[0].downloads.linux.link')"
    TOOLBOX_CHECKSUM_URL="$(echo "$JSON" | jq -r '.TBA[0].downloads.linux.checksumLink // empty')"

    curl -fL -o "$TEMP_DIR/toolbox.tar.gz" "$TOOLBOX_URL"

    if [[ -n "$TOOLBOX_CHECKSUM_URL" ]]; then
        EXPECTED="$(curl -fsSL "$TOOLBOX_CHECKSUM_URL" | awk '{print $1}')"
        ACTUAL="$(sha256sum "$TEMP_DIR/toolbox.tar.gz" | awk '{print $1}')"
        [[ "$EXPECTED" == "$ACTUAL" ]] || die "JetBrains Toolbox checksum mismatch"
    fi

    sudo mkdir -p "$INSTALL_DIR"
    sudo tar -xzf "$TEMP_DIR/toolbox.tar.gz" --strip-components=1 -C "$INSTALL_DIR"
    sudo ln -sf "$INSTALL_DIR/bin/jetbrains-toolbox" /usr/local/bin/jetbrains-toolbox

    success "JetBrains Toolbox installed"
else
    info "JetBrains Toolbox already installed"
fi

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

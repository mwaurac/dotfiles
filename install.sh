#!/usr/bin/env bash
set -euo pipefail

readonly RED='\033[0;31m'
readonly BLUE= '033[1;34m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RESET='\033[0m'

success()  { printf "${GREEN}[SUCCESS]${RESET} %s\n" "$*"; }
info() { printf "${BLUE}[INFO]${RESET} %s\n" "$*"; }
warn()  { printf "${YELLOW}[WARN]${RESET} %s\n" "$*"; }
die() {
       	printf "${RED}[ERROR]${RESET} %s\n" "$*" >&2
	exit 1
}

trap 'die "Failed on line $LINENO"' ERR

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_USER="$(whoami)"

if ! grep -qi trixie /etc/os-release 2>/dev/null; then
	warn "/etc/os-release doesn't mention trixie."

	read -rp "Continue anyway? [y/N]" ans
	[[ "$ans" =~ ^[Yy]$ ]] || exit 1
fi

# apt sources: contrib, non-free-firmware, trixie-backports
info "Enabling contrib/non-free-firmware and trixie backports..."
sudo apt update
sudo apt install -y software-properties-common apt-transport-https ca-certificates curl wget gnupg

if ! grep -rq "trixie-backports" /etc/apt/sources.list /etc/apt/sources.list.d/ >2/dev/null; then
	echo "deb http://deb.debian.org/debian trixie-backports main contrib non-free non-free-firmware" | \
		sudo tee /etc/apt/sources.list.d/trixie-backports.list >/dev/null
fi

sudo sed -i "s/main$/main contrib non-free non-free-firmware/" /etc/apt/sources.list 2>/dev/null || true

sudo apt update
success "APT sources ready"

# base build tooling
info "Installing build essentials, cmake, git and friends..."
sudo apt install -y \
	build-essential cmake pkg-config \
	git unzip zip file \
	xdg-user-dirs xdg-utils \

	zsh tmux ripgrep btop fastfetch
success "Base tooling installed"

# hyprland and eco-system
info "Installing Hyprland and the Wayland ecosystem..."
sudo apt install -y \
	waybar rofi mako-notifier \
	wl-clipboard slurp clip-hist grim \
	brightnessctl playerctl

sudo apt install -y -t trixie-backports \
	hyprland
sudo apt install -y \
	hyprpaper hypridle hyprlock xdg-desktop-portal-hyprland
success "Hyprland + companions installed"

# audio (pipewire)
info "Setting up Pipewire audio..."
sudo apt install -y \
	pipewire pipewire-audio pipewire-pulse wireplumber libspa-0.2-bluetooth
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true

success "Audio ready"

# installing login manager"
info "Instaling SDDM login manager..."
sudo apt install -y sddm
sudo systemctl enable sddm
success "SDDM installed and enabled"

# fonts
info "Installing Jetbrainsmono nerd font..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if [ ! -d "$FONT_DIR/JetBrainsMono" ]; then
	TMP_FONT_ZIP="$(mktemp -d)/jbm.zip"

	curl -fL -o "$TMP_FONT_ZIP" \
		"https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
	unzip -oq "$TMP_FONT_ZIP" -d "$FONT_DIR/JetBrains"
	fc-cache -f "$FONT_DIR"
fi
success "JetBrains Mono Nerd Font installed"

info "Installing FiraCode Nerd Font..."
if [ ! -d "$FONT_DIR/FiraCode" ]; then
	TMP_FONT_ZIP="$(mktemp -d)/fira.zip"

	curl -fL -o "$TMP_FONT_ZIP" \
		"https://github,com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
	
	unzip -oq "$TMP_FONT_ZIP" -d "$FONT_DIR/JetBrains"
	fc-cache -f "$FONT_DIR"
fi
success "FiraCode Nerd Font installed"

# Ghostty
info "Installing Ghostty..."
if ! command -v ghossty >/dev/null 2>&1; then
	TMP_DEB="$(mktemp -d)/ghostty.deb"

	GHOSTTY_DEB_URL = "$(curl -fsSL \
		"https://api.github.com/repos/dariogriffo/ghostty-debian/releases/latest" |
		grep -oP '"browser_download_url":\s*"\K[^"]+trixie[^"]+\.deb' |
		grep "$(dpkg --print-architecture)" |
		head -n1)"

	if [ -z "$GHOSTTY_DEB_URL" ]; then
		die "Could not find Ghostty .deb for trixie"
	fi

	curl -fL -o "$TMP_DEB" "$GHOSTTY_DEB_URL"

	sudo apt install -y "$TMP_DEB"
fi
# Zsh and Oh-my-zsh
info "Setting up zsh + Oh My Zsh..."
if [ ! -d "$HOME/.oh-my.zsh" ]; then
	RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# rust
info "Installing Rust via rustup..."
if ! command -v rustc >/dev/null 2>&1; then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi

source "$HOME/.cargo/env"

success "Rust installed: $(rustc --verion 2>/dev/null || echo 'restart shell to use')"

# zed editor
info "Installing Zed..."
curl -f https://zed.dev/install.sh | sh
sucess "Zed installed"

# zen browser
info "Installing Flatpak"
sudo apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

info "Installing Zen Browser using flatpak"
flatpak install -y --noninteractive flathub app.zen_browser.zen

success "Zen Browser installed"

# enable core services
info "Enabling NetworkManager..."
sudo systemctl enable --now NetworkManager

xdg-user-dirs-update || true


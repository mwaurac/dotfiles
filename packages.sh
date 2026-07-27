#!/usr/bin/env bash
# ╭─────────────────────────────────────────────╮
# │  packages.sh — Dotfiles Package Management  │
# │  Lists and installs base/desktop tools      │
# ╰─────────────────────────────────────────────╯

BASE_PACKAGES=(
    git
    curl
    wget
    unzip
    zip
    build-essential

    # Shell
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting

    # System Utilities
    network-manager
    ufw
    brightnessctl
    playerctl

    # Audio Server
    pipewire
    wireplumber

    # Clipboard & Screenshot
    wl-clipboard
    grim
    slurp
)

HYPRLAND_PACKAGES=(
    hyprland	
    hypridle
    hyprlock
    hyprpaper

    waybar
    rofi
    mako-notifier

    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk

    pavucontrol
    network-manager-gnome
    xdg-user-dirs
    yazi
)

install_packages() {
    info "Installing base and desktop packages..."
    sudo apt install -y \
        "${BASE_PACKAGES[@]}" \
        "${HYPRLAND_PACKAGES[@]}"
}

configure_services() {
    info "Configuring and enabling services..."
    sudo systemctl enable NetworkManager

    sudo ufw allow OpenSSH
    sudo ufw --force enable
}

install_fonts() {
    info "Installing FiraCode Nerd Font..."
    mkdir -p "$HOME/Downloads"

    if [[ -f "$HOME/Downloads/FiraCode.zip" ]]; then
        warn "FiraCode.zip already exists. Using existing download."
    else
        wget \
            -q \
            -O "$HOME/Downloads/FiraCode.zip" \
            https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip
    fi

    mkdir -p "$HOME/.local/share/fonts/FiraCode"
    unzip \
        -o \
        "$HOME/Downloads/FiraCode.zip" \
        -d "$HOME/.local/share/fonts/FiraCode"

    fc-cache -fv >/dev/null
}

install_ghostty() {
    if command -v ghostty >/dev/null 2>&1; then
        warn "Ghostty is already installed. Skipping."
        return
    fi

    info "Installing Ghostty terminal..."
    mkdir -p "$HOME/Downloads"

    if [[ -f "$HOME/Downloads/ghostty.deb" ]]; then
        warn "ghostty.deb file already exists. Using existing download."
    else
        # Correct typo from previous script "ghossty.deb" -> "ghostty.deb"
        wget \
            -q \
            -O "$HOME/Downloads/ghostty.deb" \
            "https://github.com/dariogriffo/ghostty-debian/releases/download/1.3.1%2B5/ghostty_1.3.1-5.trixie_amd64.deb"
    fi

    sudo apt install -y "$HOME/Downloads/ghostty.deb"
}

install_starship() {
    if command -v starship >/dev/null 2>&1; then
        warn "Starship prompt is already installed. Skipping."
        return
    fi

    info "Installing Starship shell prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
}

configure_pam_hyprlock() {
    local PAM_HYPRLOCK="/etc/pam.d/hyprlock"
    if [ ! -f "$PAM_HYPRLOCK" ]; then
        info "Installing PAM configuration for hyprlock..."
        sudo tee "$PAM_HYPRLOCK" > /dev/null << 'EOF'
#%PAM-1.0
auth       include      common-auth
account    include      common-account
password   include      common-password
session    include      common-session
EOF
        success "PAM configuration for hyprlock installed."
    else
        warn "PAM configuration for hyprlock is already present, skipping."
    fi
}

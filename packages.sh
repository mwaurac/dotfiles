#!/usr/bin/env bash

BASE_PACKAGES=(
    git
    curl
    wget
    unzip
    zip
    build-essential

    network-manager

    pipewire
    wireplumber

    brightnessctl
    playerctl

    wl-clipboard
    grim
    slurp

    ufw
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
)

install_packages() {

    info "Installing packages..."

    sudo apt install -y \
        "${BASE_PACKAGES[@]}" \
        "${HYPRLAND_PACKAGES[@]}"
}

configure_services() {

    info "Configuring services"

    sudo systemctl enable NetworkManager

    sudo ufw allow OpenSSH
    sudo ufw --force enable
}

install_fonts() {

    info "Installing FiraCode Nerd Font"

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

    info "Installing Ghostty"

    mkdir -p "$HOME/Downloads"

    if [[ -f "$HOME/Downloads/ghossty.deb" ]]; then
	warn "ghostty.deb file already exists. Using existing download."
    else
        wget \
            -q \
            -O "$HOME/Downloads/ghostty.deb" \
            "https://github.com/dariogriffo/ghostty-debian/releases/download/1.3.1%2B5/ghostty_1.3.1-5.trixie_amd64.deb"
    fi

    sudo apt install -y "$HOME/Downloads/ghostty.deb"
}

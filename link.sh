#!/usr/bin/env bash
set -e

CONFIG_DIR="$(pwd)"

mkdir -p ~/.config

ln -sfn "$CONFIG_DIR/hypr" ~/.config/hypr
ln -sfn "$CONFIG_DIR/waybar" ~/.config/waybar
ln -sfn "$CONFIG_DIR/mako" ~/.config/mako
ln -sfn "$CONFIG_DIR/ghostty" ~/.config/ghostty
ln -sfn "$CONFIG_DIR/rofi" ~/.config/rofi

echo "Dotfiles linked."

#!/bin/bash
set -e  # Exit on error

# Packages to install NORMALLY
packages=(firefox alacritty neovim git bluez fish)

AURPackages=(hyprland hyprpaper waybar rofi-lbonn-wayland brightnessctl xdg-desktop-portal-hyprland network-manager-applet ttf-jetbrains-mono-nerd ttf-font-awesome \
vesktop)

# Colors for output (optional, just for readability)

PURPLE="\033[1;95m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
ERRORRED="\033[0;31m"
NC="\033[0m" # No Color

log() {
    echo -e "${GREEN}[+]  $1 "
}

error() {
    echo -e "${ERRORRED}[!] $1${NC}"
}

# Implementation

install_package() {
    if ! pacman -Qi "$1" &> /dev/null; then
        log "${GREEN}Installing $1..."
        sudo pacman -S --noconfirm "$1"
    else
        log "${YELLOW}is already installed."
    fi
}

install_aur_package() {
    if ! pacman -Qi "$1" &> /dev/null; then
        log "${GREEN}Installing AUR package $1..."
        yay -S --noconfirm "$1"
    else
        log "${YELLOW}$1 is already installed."
    fi
}
#setups

Install_YAY() {
    if ! command -v yay &> /dev/null; then
        log "${GREEN}Installing yay (AUR helper)..."
        sudo pacman -S --noconfirm --needed base-devel git

        tempdir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$tempdir/yay"
        pushd "$tempdir/yay" > /dev/null
        makepkg -si --noconfirm
        popd > /dev/null
        rm -rf "$tempdir"
        
        log "${GREEN}yay installed successfully."
    else
        log "${YELLOW}yay is already installed."
    fi
}

#
# Individual apps that are strugglefests so we need to ensure they are gracefully installed
#
Install_Steam() {
        if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        log "${PURPLE}Enabling multilib..."
        sudo sed -i '/\[multilib\]/,/Include/ s/^#//' /etc/pacman.conf
        sudo pacman -Sy
        log "${GREEN}Multilib has been set enabled."
	install_package steam-native-runtime
    else
        log "${YELLOW}Multilib already enabled."
    fi
}

install_hyprland() {
    log "Installing Hyprland and essential packages..."

    # Core
    yay -S --noconfirm hyprland hyprpaper waybar rofi-lbonn-wayland

    # Optional but helpful
    yay -S --noconfirm kitty neovim thunar pavucontrol brightnessctl \
        xdg-desktop-portal-hyprland network-manager-applet \
        ttf-jetbrains-mono-nerd ttf-font-awesome

    log "Hyprland and related tools installed."
}


# Actual Installation Part is down here
Install_YAY
Install_Steam

for pkg in "${packages[@]}"; do
   install_package "$pkg"
done

for pkg in "${AURPackages[@]}"; do
   install_aur_package "$pkg"
done




for package in "${packages[@]}"; do
    case "$package" in
        bluez)
            if ! systemctl is-enabled --quiet bluetooth.service; then
                log "Enabling Bluetooth service..."
                sudo systemctl enable --now bluetooth.service
            else
                log "${YELLOW}Bluetooth service already enabled.${NC}"
	    fi
            ;;
	fish)
		if [[ "$(basename "$SHELL")" != "fish" ]]; then
                	log "Changing shell to Fish..."
                	chsh -s "$(which fish)"
		else 
			log "${YELLOW}Shell is already Fish"
		fi
	;;
    esac
done

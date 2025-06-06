#!/bin/bash
#/run/media/fur3/Ventoy
set -e # Exit on error

# Packages to install NORMALLY
packages=(alacritty dosfstools cups pavucontrol arduino-ide git bluez fish hyfetch fastfetch prismlauncher nano steam-native-runtime
  hyprland waybar brightnessctl xdg-desktop-portal-hyprland network-manager-applet ttf-jetbrains-mono-nerd ttf-font-awesome
  plymouth steam-native-runtime)
AURPackages=(rofi-theme-applet-1080p mpvpaper vesktop)

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
  if ! pacman -Qi "$1" &>/dev/null; then
    log "${GREEN}Installing $1..."
    sudo pacman -S --noconfirm "$1"
  else
    log "${YELLOW}$1 is already installed."
  fi
}

install_aur_package() {
  if ! pacman -Qi "$1" &>/dev/null; then
    log "${GREEN}Installing AUR package $1..."
    yay -S --noconfirm "$1"
  else
    log "${YELLOW}$1 is already installed."
  fi
}
#setups

Install_YAY() {
  if ! command -v yay &>/dev/null; then
    log "${GREEN}Installing yay (AUR helper)..."
    sudo pacman -S --noconfirm --needed base-devel git

    tempdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tempdir/yay"
    pushd "$tempdir/yay" >/dev/null
    makepkg -si --noconfirm
    popd >/dev/null
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
    if [[ $SHELL != "/usr/bin/fish" ]]; then
      log "Changing shell to Fish..."
      chsh -s /usr/bin/fish
    else
      log "${YELLOW}Shell is already Fish"
    fi
    ;;
  alacritty)
    log "${PURPLE}Running interactive terminal theme selector. My personal recomendation is : Terminal-App"
    npx alacritty-themes
    alacritty migrate
    ;;
  rofi-theme-applet-1080p)
    log "${PURPLE}Running interactive ROFI theme selector. My personal recomendation is : Arthur"
    ;;
  arduino-ide)
    log "${NC}Configuring arduino-ide.."
    sudo usermod -a -G uucp $USER
    ;;
  cups)
    log "${NC}Configuring cups.."
    sudo systemctl enable --now cups
    ;;
  esac
done

for package in "${AURPackages[@]}"; do
  case "$package" in
  rofi-theme-applet-1080p)
    log "${PURPLE}Running interactive ROFI theme selector. My personal recomendation is : Arthur"
    rofi-theme-selector

    #configure a button press to activate the mainmod to launch programs
    touch "/home/$USER/.config/hypr/mainMod.sh"
    echo '#!/usr/bin/env bash
		# ~/.local/bin/launcher-toggle.sh

		LAUNCHER="rofi"

		if pgrep -x $LAUNCHER > /dev/null; then
  		pkill $LAUNCHER
		else
		# launch in background so Hyprland doesnt block
		   $LAUNCHER -show drun &
		fi' >"/home/$USER/.config/hypr/mainMod.sh"

    chmod +x /home/"$USER"/.config/hypr/mainMod.sh

    ;;
  esac
done
SCRIPT_DIR=$(dirname "$(realpath "$0")")
mv -f "$SCRIPT_DIR"/src/hypr* "$HOME/.config/hypr/"

sudo mv -f "$SCRIPT_DIR"/src/fish/weatherService* "/etc/systemd/system/"

sudo systemctl daemon-reexec && sudo systemctl daemon-reload
sudo systemctl enable --now weather-fetch.timer

mv -f "$SCRIPT_DIR"/src/fish/* "$HOME/.config/fish/"

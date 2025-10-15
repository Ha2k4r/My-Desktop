#!/bin/sh
#
#
#	Author	-	Stolasbirb/Ha2k4r
#	Repo	-	https://github.com/Ha2k4r/My-Desktop/
#	Version -       0.1
#
#

# Packages

# Removing these may break individual apps but some of these are nice to haves that i always use for development and general use
packages=(krita swaync firefox hyprland zip unzip bc jq dosfstools cups pavucontrol arduino git bluez fish fastfetch nano waybar brightnessctl plymouth hyprlock kitty rofi dunst libnotify inotify-tools wget acpid swaybg
	slurp grim playerctl gammastep kdeconnect iproute2 xdg-desktop-portal-hyprland)

AURPackages=(vesktop)

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
ORANGE="$(tput setaf 214)"
WARNING="$(tput setaf 1)"
YELLOW="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
SKY_BLUE="$(tput setaf 6)"
RESET="$(tput sgr0)"

# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
    echo "${ERROR}  This script should ${WARNING}NOT${RESET} be executed as root!! Exiting......."
    printf "\n%.0s" {1..2}
    exit 1
fi

# Check /etc/os-release to see if this is an Ubuntu or Debian based distro
if grep -iq '^\(ID_LIKE\|ID\)=.*\(debian\|ubuntu\)' /etc/os-release >/dev/null 2>&1; then
    echo "${ERROR} This script can only be run on a arch based distro, not Ubuntu or Debian. Exiting........"
	exit 1
fi

clear

install_package() {
  if ! pacman -Qi "$1" &>/dev/null; then
    echo "${GREEN}Installing : ${SKY_BLUE} $1 ${RESET}. . ."
    sudo pacman -S --noconfirm "$1"
  else
    echo "${NOTE}$1 is already installed. ${RESET}"
  fi
}

install_aur_package() {
  if ! pacman -Qi "$1" &>/dev/null; then
    echo "${GREEN}Installing AUR package ${SKY_BLUE}$1 ${RESET}. . ."
    yay -S --noconfirm "$1"
  else
    echo "${NOTE}$1 is already installed.${RESET}"
  fi
}

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

    echo "${GREEN}yay installed successfully.${RESET}"
  else
    echo "${NOTE}yay is already installed.${RESET}"
  fi
}


#
# Implementation
#

for pkg in "${packages[@]}"; do
  install_package "$pkg"
done

Install_YAY
for pkg in "${AURPackages[@]}"; do
  install_aur_package "$pkg"
done

#
# Configuration
#


for package in "${packages[@]}"; do
  case "$package" in
  bluez)
    if ! systemctl is-enabled --quiet bluetooth.service; then
      echo "${GREEN}Enabling Bluetooth service...${RESET}"
      sudo systemctl enable --now bluetooth.service
    else
      log "${YELLOW}Bluetooth service already enabled.${RESET}"
    fi
    ;;
  fish)
    if [[ $SHELL != "/usr/bin/fish" ]]; then
      echo "${GREEN}Changing shell to Fish...${RESET}"
      sudo chsh -s /usr/bin/fish
    else
      echo "${NOTE}Shell is already Fish${RESET}"
    fi
    ;;
  arduino-ide)
    echo "${GREEN}Configuring arduino-ide..${RESET}"
    sudo usermod -a -G uucp $USER
    ;;
  cups)
    echo "${GREEN}Configuring cups..${RESET}"
    sudo systemctl enable --now cups
    ;;
  esac
done



for package in "${AURPackages[@]}"; do
  case "$package" in
  vesktop)
    ;;
  esac
done


# Fonts

curl -L -o /tmp/tmpfont.zip 'https://www.dropbox.com/scl/fi/fcjwlalz1zq19a05tdw0f/elenapan-dotfiles-fonts.zip?dl=0&e=1&rlkey=uljkjoyi5qipi6hc9ju9ibk4o&st=zwqrvroc'

unzip -d ~/.local/share/fonts tmp/tmpfont.zip

fc-cache -v

# Installing the dotfiles

#git clone https://github.com/elenapan/dotfiles

#cd dotfiles

#cp -r config/{sway,eww,dunst,fontconfig,kitty,rofi} ~/.config

# Wallpaper
#mkdir Pictures Pictures/wallpapers/
#curl --output ~/Pictures/wallpapers/ https://i.redd.it/zz55pru3ee0f1.png



# Hyprland Dotfiles

SCRIPT_DIR=$(dirname "$(realpath "$0")")

rm -rf "$HOME/.config/hypr/"
cp -rf "$SCRIPT_DIR"/src/hypr* "$HOME/.config/"

#sudo cp -f "$SCRIPT_DIR"/src/fish/weatherService/weather-fetch.service "/etc/systemd/system/"
#sudo cp -f "$SCRIPT_DIR"/src/fish/weatherService/weather-fetch.timer "/etc/systemd/system/"
#sudo cp -f "$SCRIPT_DIR"/src/fish/WeatherFetchBIN/fetch_weather.sh "/usr/bin/"

#sudo chmod +x "/usr/bin/fetch_weather.sh"

#log "${GREEN}Finishing up now.."

#sudo systemctl daemon-reexec && sudo systemctl daemon-reload
#sudo systemctl enable --now weather-fetch.timer

#cp -rf "$SCRIPT_DIR"/src/fish/* "$HOME/.config/fish/"

sudo cp -f "$SCRIPT_DIR"/src/waybar/config.jsonc "/etc/xdg/waybar/"

sudo cp -f "$SCRIPT_DIR"/src/waybar/style.css "/etc/xdg/waybar/"
#cp -rf "$SCRIPT_DIR"/src/kitty/kitty.conf ~/.config/kitty/

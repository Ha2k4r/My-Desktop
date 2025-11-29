#! /bin/bash

# _____ _        _           ______ _      _
#/  ___| |      | |          | ___ (_)    | |
#\ `--.| |_ ___ | | __ _ ___ | |_/ /_ _ __| |__
# `--. \ __/ _ \| |/ _` / __|| ___ \ | '__| '_ \
#/\__/ / || (_) | | (_| \__ \| |_/ / | |  | |_) |
#\____/ \__\___/|_|\__,_|___/\____/|_|_|  |_.__/
#
# trans rights! yes, but my coding is a trans wrong
#


#ehh, makes it a lil easyer to reuse my template
name_of_program='Pterodactyl'
goodbye_message='goodbye, and have a great day!'

#defaults
noconfirm=false
nochecks=false

parse_arguments() {
  while test $# -gt 0; do
    case "$1" in
    --help | -h | help)
      # Return this message and exit
      echo -e "This script installs $name_of_program a open-source game management panel to your device.
usage: PROGRAM {Flags..}

Valid Flags:
-h,  --help, shows this menu and exits
--noconfirm, Never prompts the user and assumes defaults
--nochecks,  Does not perform system safety checks and runs blindly"
      exit 0
      ;;
    --noconfirm)
        noconfirm=true
        shift
      ;;
    --nochecks)
        nochecks=true
        shift
      ;;
    *)
      echo -e "error: unexpected argument : '${*}' found
usage ./hardening.bash [Flags]
for more information, try '--help'"
      exit 1
      ;;
    esac
  done
}

# Function to ensure the script is run as root
check_root() {
if [ "$nochecks" = false ]; then
    if [ "$(id -u)" -ne 0 ]; then
      echo "This script must be run as root. try again with 'sudo' or as the root user; su."
      exit 1
    fi
  fi
}
check_operating_system() {
  if [ "$nochecks" = false ]; then
    if !(grep -q "Arch Linux" /etc/os-release); then
      echo "This script can only be used on Arch Linux."
      exit 1
    fi
  fi
}

update_system() {
  echo "Updating the system..."
  pacman -Syu --noconfirm --needed
}
prompt_user() {
  local answer
  local prompt="$1"
  while true; do
    read -r -p "$prompt (Y/n) " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      return 0 #true
    elif [[ "$answer" =~ ^[Nn]$ ]]; then
      return 1 #false
    else
      echo "Invalid input, please type Y or N."
    fi
  done
}

implementation() {
  echo "haiiiii ! :3"
}

promptuser() {
  if !($noconfirm) ; then
    if prompt_user "This script will modify your System, and install $name_of_program.
Please enter 'N' to exit or 'Y' to continue. "; then
       implementation
    else
      echo "User denied action. Exiting."
      return 0
    fi
  else
    implementation
  fi
}
main() {
  parse_arguments "$@"
  check_root
  check_operating_system
  promptuser
  printf "\nEND OF SCRIPT\n\n$goodbye_message"
  return 0
}
main "$@"

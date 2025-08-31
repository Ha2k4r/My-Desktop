parse_arguments() {
  while test $# -gt 0; do
    case "$1" in
    --help | -h | help)
      # Return this message and exit
      echo -e 'This interactive script hardens your device.
Valid Flags:
-h,  --help, shows this menu and exits'
      exit 1
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
  if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. try again with 'sudo' or as the root user; su."
    exit 1
  fi
}

# Function to update the system
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
  echo "$tmp"
}
main() {
  #check_root
  #parse_arguments "$@"

  if prompt_user "Do you want cheese ?"; then
    echo "cheese is true"
  else
    echo "cheese is false"
  fi
}
main "$@"

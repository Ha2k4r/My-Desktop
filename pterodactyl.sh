#! /bin/bash


creator_line1=' _____ _        _           ______ _      _     '
creator_line2='/  ___| |      | |          | ___ (_)    | |    '
creator_line3='\ `--.| |_ ___ | | __ _ ___ | |_/ /_ _ __| |__  '
creator_line4=' `--. \ __/ _ \| |/ _` / __|| ___ \ | .__| |_ \ '
creator_line5='/\__/ / || (_) | | (_| \__ \| |_/ / | |  | |_) |'
creator_line6='\____/ \__\___/|_|\__,_|___/\____/|_|_|  |_.__/ '
creator_line7='
trans rights! yes, but my coding is a trans wrong'




#ehh, makes it a lil easyer to reuse my template
name_of_program='Pteradactyl'
goodbye_message='Thank you for using my program, goodbye, and have a great day!'

#defaults
noconfirm=false
nochecks=false
nocolor=false
quiet=false
verbose=false

#weird funky stuff
aur_sandboxing=false


### prebby colors (auto-disabled if piped)

if [ -t 1 ]; then
    # Green 
    OK="$(tput setaf 2)[OK]$(tput sgr0)"

    # Red
    ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"

    # Yellow
    NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"

    # Blue 
    INFO="$(tput setaf 4)[INFO]$(tput sgr0)"

    # yellow
    WARN="$(tput setaf 3)[WARN]$(tput sgr0)"

    # Cyan for prompts
    ACTION="$(tput setaf 6)[ACTION]$(tput sgr0)"

    # Raw color 
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    MAGENTA="$(tput setaf 5)"
    CYAN="$(tput setaf 6)"
    WHITE="$(tput setaf 7)"  
    C_RESET="$(tput sgr0)"
else
    # triggered when output is NOT a terminal 
    OK="[OK]"
    ERROR="[ERROR]"
    NOTE="[NOTE]"
    INFO="[INFO]"
    WARN="[WARN]"
    ACTION="[ACTION]"

    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    MAGENTA=""
    CYAN=""
    WHITE=""
    C_RESET=""
fi

log() {
  local msg="$1"
  local force="$2"

  if [[ "$quiet" == true && "$force" != "force" ]]; then
    return 0
  fi  
  
  if [[ "$nocolor" == true ]]; then
    #strip all forms of color
    msg=$(printf '%s' "$msg" \
         | sed -r 's/\x1B\[[0-9;]*[mK]//g')
  fi 

  if [[ "$verbose" == true ]]; then
    local timestamp="[$(date +"%Y-%m-%d %H:%M:%S")] "
  else
    local timestamp=""
  fi

  echo "${timestamp}${msg}${C_RESET}"
}

error() {
  #ignores silent argument parse and prints in a nicely formated way
  log "${RED}[ERROR] $*" force
}

#functions area
parse_arguments() {
  while test $# -gt 0; do
    case "$1" in
    --help | -h | help)
      # Return this message and exit
      echo -e "This script installs $name_of_program a open-source game management panel to your device.
usage: PROGRAM {Flags..}

Valid Flags:
-h,  --help,    shows this menu and exits
--noconfirm,    Never prompts the user and assumes defaults
--nochecks,     Does not perform system safety checks and runs blindly
-nc, --nocolor, Does not show colored output :(
-q, --quiet,    Silences non required information
-v, --verbose,  Output has timestamps"
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
    --nc | --nocolor | --nocolors)
	nocolor=true
	shift
      ;;
    -q | --quiet)
    	quiet=true
	shift
      ;;
    -v | --verbose)
	verbose=true
	shift
      ;;
    *)
      error "unexpected argument : '${*}' found
usage PROGRAM [Flags]
for more information, try '--help'"
      exit 1
      ;;
    esac
  done
}

check_root() {
  if [ "$nochecks" = false ]; then
    if [ "$(id -u)" -ne 0 ]; then
      error "This script must be run as root. try again with 'sudo' or as the root user; su."
      exit 1
    fi 
  fi
}

check_operating_system() {
  if [ "$nochecks" = false ]; then
    if !(grep -q "Arch Linux" /etc/os-release); then
      error "This script can only be used on Arch Linux."
      exit 1
    fi
  fi
}
install_yay(){
  sudo pacman -S --needed --noconfirm git base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  pushd /tmp/yay
  makepkg -si --noconfirm
  popd
}
check_yay_installed() {
  if [ "$nochecks" = false ]; then
    if ! command -v yay &> /dev/null; then
      if [ "$noconfirm" = false ]; then
        if prompt_user "yay is not installed, and is required by this program, would you like to install it?"; then
	 install_yay
        else
	 exit 0
        fi 
      else
        echo "yay not found – installing..."
	install_yay
      fi
    fi
  fi
}

update_system() {
  log "Updating the system..."
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
      error "Invalid input, please type Y or N."
    fi
  done
}

implementation() {
  yay -S --noconfirm pterodactyl-panel pterodactyl-wings php-fpm php83-dblib redis mysql

}

modify_system_dialog() {
  if !($noconfirm) ; then 
    if prompt_user "This script will modify your System, and install $name_of_program. 
Please enter 'N' to exit or 'Y' to continue. "; then
      return 0
    else
      error "User denied action. Exiting."
      exit 1 
    fi 
  else
    return 0  
  fi 
}
print_creator(){
  log "
${BLUE}$creator_line1
${MAGENTA}$creator_line2
${WHITE}$creator_line3
${WHITE}$creator_line4
${MAGENTA}$creator_line5
${BLUE}$creator_line6
${GREEN}$creator_line7"
}

main() {
  parse_arguments "$@"
  check_root
  check_operating_system
  modify_system_dialog
  implementation

  log "${GREEN}$goodbye_message"
}
main "$@"

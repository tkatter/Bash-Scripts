#!/usr/bin/bash
# lib_utils.sh: Common utilities and functions for the dotfiles setup scripts

export INSTALL_DIR=$(pwd)

## Colors
export BLUE='\e[34m'
export CYAN='\e[36m'
export GREEN='\e[32m'
export MAGENTA='\e[35m'
export NC='\e[0m' # No Color (reset)
export RED='\e[31m'
export WHITE='\e[37m'
export YELLOW='\e[33m'

## Define formatting
export BOLD='\e[1m'
export ERROR_PREFIX="${BOLD}${RED}ERROR:${NC}"
export UNDERLINE='\e[4m'

## Define dirs
export CONFIG_DIR="$HOME/.config"
export LOCAL_BIN="$HOME/.local/bin"
export USR_BIN="/usr/local/bin"
export DOTS_DIR="$HOME/dotfiles"

## Utility functions
#> Generates a preformatted error message and prints
#> `msg`($1) and optionally exits with `"exit"`($2)
error_msg() {
  local msg="$1"
  echo -e "$ERROR ${RED}${msg}${NC}" >&2
  if [[ "$2" == "exit" ]]; then
    exit 1
  fi
}

#> Generates a preformatted will install message and installs `cmd`($1)
will_install() {
  local cmd="$1"
  echo -e "${BLUE}'$cmd' not installed${NC}, ${BOLD}${GREEN}installing '$cmd'...${NC}"
  sudo apt update 2>/dev/null
  sudo apt install $cmd -y 2>/dev/null
}

#> Diffs files to see whether to bother making backup
diff_n_bkp() {
  local new="$1"
  local old="$2"

  if ! diff "$new" "$old" &>/dev/null; then
    echo -e "${BLUE}$old found... ${BOLD}making backup: $old.bak${NC}"
    mv "$old" "$old.bak"
  fi
}

#> Install rustup and the rust toolchain
install_rust() {
  if ! command -v "cargo" &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    rustup update
    source "$HOME/.cargo/env"

    cargo install --locked wild-linker
    if [[ ! -d "$HOME/.cargo" ]]; then
      mkdir -p "$HOME/.cargo"
    fi

    cat "$DOTS_DIR/cargo/config.toml" >>"$HOME/.cargo/config.toml"

    uncomment_line '^# . "$HOME/.cargo/env"' '. "$HOME/.cargo/env"' "$HOME/.bashrc"
  fi
}

#> Basic install function that sources the install_*.sh file
install_it() {
  local pkg="$1"
  local script=$(ls -1 $INSTALL_DIR | grep $pkg)

  if ! command -v "$pkg" &>/dev/null; then
    cd $INSTALL_DIR
    echo -e "${YELLOW}Installing $pkg...${NC}"
    source "$INSTALL_DIR/$script"
  else
    echo -e "${YELLOW}skipping '$pkg' - already installed ${NC}"
  fi
}

#> Function to uncomment a specific line of `.bashrc`
#> Uncomments a line in `file`($3)
#> Searches for `search_regex`($1) and replaces with `replacement_line`($2)
uncomment_line() {
  local search_regex="$1"
  local replacement_line="$2"
  local file="$3"

  if [[ ! -f "$file" ]]; then
    error_msg "Target file '$file' for uncomment_line not found!"
    return 1
  fi

  if grep -q "^${replacement_line}" "$file"; then
    echo -e "${BLUE}Line already uncommented: '$replacement_line'${NC}"
  else
    if grep -q "$search_regex" "$file"; then
      echo -e "${YELLOW}Uncommenting line matching '$search_regex' in $file${NC}"
      sed -i.bak "s|$search_regex|$replacement_line|" "$file"
      echo -e "${BLUE}Backup created: ${file}.bak${NC}"
    else
      echo -e "${BLUE}Line matching '$search_regex' not found in $file. Appending it...${NC}"
      echo "$replacement_line" >>"$file"
    fi
  fi
}

#> Retrieves host info for global variables that will be individually
#> processed in each package's install script based on how they interpret
#> host architecture strings for their releases.
get_host_info() {
  local os_name_raw=$(uname -s)
  local arch_name_raw=$(uname -m)

  case "$os_name_raw" in
  Linux*)
    DETECTED_OS="linux"
    ;;
  Darwin*)
    DETECTED_OS="darwin" # Using 'darwin' as a neutral standardized term for macOS
    ;;
  MINGW* | CYGWIN* | MSYS*)
    DETECTED_OS="windows"
    ;;
  *)
    error_msg "Unsupported OS: $os_name_raw. Cannot determine architecture." "exit"
    ;;
  esac

  case "$arch_name_raw" in
  x86_64)
    DETECTED_ARCH="amd64" # Using 'amd64' as a neutral standardized term for x86_64
    ;;
  aarch64 | arm64)
    DETECTED_ARCH="arm64"
    ;;
  i686 | i386)
    DETECTED_ARCH="386"
    ;;
  *)
    error_msg "Unsupported Architecture: $arch_name_raw. Cannot determine asset name." "exit"
    ;;
  esac

  echo -e "${CYAN}Detected System: OS=${BOLD}${DETECTED_OS}${NC}, Arch=${BOLD}${DETECTED_ARCH}${NC}"
}

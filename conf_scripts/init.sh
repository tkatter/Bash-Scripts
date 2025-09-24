#!/usr/bin/bash
# This script is meant for initial configuration instal for dotfiles
# from tkatter/dotfiles

source "$(dirname "$0")/lib_utils.sh"

## Configure git
#############################################
## Install if necessary
if ! command -v "git" &>/dev/null; then
  will_install "git"
fi

## Clone dotfiles repo
cd $HOME
echo -e "${BOLD}${YELLOW}cloning tkatter/dotfiles into $DOTS_DIR...${NC}"
git clone https://github.com/tkatter/dotfiles.git

## Prepare git config location
if [[ -f "$CONFIG_DIR/git/config" ]]; then
  echo -e "${BLUE}git config found... ${BOLD}making backup: $CONFIG_DIR/git/config.bak${NC}"
  mv "$CONFIG_DIR/git/config" "$CONFIG_DIR/git/config.bak"
else
  mkdir -p "$CONFIG_DIR/git"
fi

## Copy git configs
##>>>>>> no slash for src, slash for dst parent
#>>>> rsync -bcrv src dest/
#>>ex> rsync -bcrv "$DOTS_DIR/git" "$HOME/.config/"
cp "$DOTS_DIR/git/"* "$CONFIG_DIR/git/"

echo -e "${GREEN}finished git config!${NC}"

## Configure bash
#############################################
echo -e "${YELLOW}beginning bash config...${NC}"

## Make backups
if [[ -f "$HOME/.bashrc" ]]; then
  diff_n_bkp "$DOTS_DIR/.bashrc" "$HOME/.bashrc"
fi

if [[ -f "$HOME/.bash_aliases" ]]; then
  diff_n_bkp "$DOTS_DIR/.bash_aliases" "$HOME/.bash_aliases"
fi

## Copy bash configs
cp "$DOTS_DIR/.bashrc" "$HOME/"
cp "$DOTS_DIR/.bash_aliases" "$HOME/"
echo -e "${BOLD}${GREEN}.bashrc configured!${NC}"

## Install `bat` for 'cat' bash alias
#############################################
if ! command -v "batcat" &>/dev/null; then
  will_install "bat"

  ## Symlink batcat to bat (ubuntu/debian)
  if [[ ! -d "$HOME/.local/bin" ]]; then
    mkdir -p "$HOME/.local/bin"
  fi

  sudo ln -s $(command -v "batcat") "$HOME/.local/bin/bat"
  echo -e "${BOLD}${GREEN}'bat' installation complete!${NC}"
fi

## Neofetch configuration
#############################################
if ! command -v "neofetch" &>/dev/null; then
  will_install "neofetch"
fi

if [[ -f "$CONFIG_DIR/neofetch/config.conf" ]]; then
  diff_n_bkp "$DOTS_DIR/neofetch/config.conf" "$CONFIG_DIR/neofetch/config.conf"
else
  mkdir -p "$CONFIG_DIR/neofetch"
  cp "$DOTS_DIR/neofetch/config.conf" "$CONFIG_DIR/neofetch/"
fi
echo -e "${BOLD}${GREEN}'neofetch' configured!${NC}"

## Install tree because I seem to always use it and it's never installed
#############################################
if ! command -v "tree" &>/dev/null; then
  will_install "tree"
fi

## Install jq - required for other installs
#############################################
if ! command -v "jq" &>/dev/null; then
  will_install "jq"
fi

## Install clang - required for other installs
#############################################
if ! command -v "clang" &>/dev/null; then
  will_install "clang"
fi

## Additional configuration/setup
#############################################
cd $INSTALL_DIR
source "$INSTALL_DIR/install_repl.sh"

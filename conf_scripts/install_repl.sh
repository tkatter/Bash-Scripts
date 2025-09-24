#!/usr/bin/bash

source "$(dirname "$0")/lib_utils.sh"

## Additional configuration/setup
#############################################
options() {
  echo -e "\n${BOLD}${MAGENTA}--- Optional Software Installation ---${NC}"
  echo -e "Select an option below:"
  echo -e "  ${MAGENTA}[a] ${BOLD}${CYAN}ALL${NC}"
  echo -e "  ${MAGENTA}[b] ${BOLD}${CYAN}rust${NC}"
  echo -e "  ${MAGENTA}[c] ${BOLD}${CYAN}nvim${NC}"
  echo -e "  ${MAGENTA}[d] ${BOLD}${CYAN}ripgrep${NC}"
  echo -e "  ${MAGENTA}[e] ${BOLD}${CYAN}fd${NC}"
  echo -e "  ${MAGENTA}[f] ${BOLD}${CYAN}fzf${NC}"
  echo -e "  ${RED}[q] ${BOLD}${RED}quit${NC}"
}

configure_nvim() {
  if [[ -d "$CONFIG_DIR/nvim" ]]; then
    echo -e "${BLUE}'nvim' config found... ${BOLD}making backup: $CONFIG_DIR/nvim.bak${NC}"
    tar -C "$CONFIG_DIR" -zcf "$CONFIG_DIR/nvim.tar.gz" nvim
    rm -rf "$CONFIG_DIR/nvim"
  else
    mkdir -p "$CONFIG_DIR"
  fi

  cd $CONFIG_DIR
  echo -e "${YELLOW}Cloning into tkatter/nvim...${NC}"
  git clone "https://github.com/tkatter/nvim.git"
  cd "$CONFIG_DIR/nvim"
  echo -e "${YELLOW}Checking out linux_conf${NC}"
  git checkout linux_conf

  ## Install unzip - required for node
  if ! command -v "unzip" &>/dev/null; then
    will_install "unzip"
  fi

  if ! command -v "npm" &>/dev/null; then
    echo -e "${YELLOW}Installing node and fnm (smh) for LSPs${NC}"
    curl -o- https://fnm.vercel.app/install | bash -s -- --skip-shell -d "$HOME/.local/share/fnm"

    ## Basically - manually src `fnm`
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env)"

    fnm install 24

    ## Add fnm to .bashrc since it was skipped ^
    echo '# fnm' >>"$HOME/.bashrc"
    echo 'FNM_PATH="$HOME/.local/share/fnm"' >>"$HOME/.bashrc"
    echo 'if [ -d "$FNM_PATH" ]; then' >>"$HOME/.bashrc"
    echo '  case ":$PATH:" in' >>"$HOME/.bashrc"
    echo '  *":$FNM_PATH:"*) : ;; # already in PATH, do nothing' >>"$HOME/.bashrc"
    echo '  *) export PATH="$FNM_PATH:$PATH" ;;' >>"$HOME/.bashrc"
    echo '  esac' >>"$HOME/.bashrc"
    echo '  eval "$(fnm env)"' >>"$HOME/.bashrc"
    echo 'fi' >>"$HOME/.bashrc"
  fi
}

nvim_install_options() {
  echo -e "${BOLD}${YELLOW}Select an install method for nvim:${NC}"
  echo -e "  ${MAGENTA}[a] ${BOLD}${CYAN}configured [tkatter/nvim configs]${NC}"
  echo -e "  ${MAGENTA}[b] ${BOLD}${CYAN}default [no config]${NC}\n"
  echo -e "  ${RED}[q] ${BOLD}${RED}back${NC}"
  read -p "Option [a]: " nvim_install
  case "$nvim_install" in
  a)
    install_it "nvim"
    configure_nvim
    ;;
  b)
    install_it "nvim"
    ;;
  q) break ;;
  esac
}

input=""

while [[ "$input" != "q" ]]; do
  options
  read -p "Option [a]: " input
  case "$input" in
  a)
    if ! command -v "cargo" &>/dev/null; then
      echo -e "${YELLOW}Installing rust...${NC}"
      install_rust
    else
      echo -e "${YELLOW}skipping 'rust' - already installed ${NC}"
    fi

    install_it "rg"
    install_it "fd"
    install_it "fzf"
    install_it "nvim"

    cd $INSTALL_DIR
    configure_nvim

    exit 0
    ;;
  b)
    if ! command -v "cargo" &>/dev/null; then
      echo -e "${YELLOW}Installing rust...${NC}"
      install_rust
    else
      echo -e "${YELLOW}skipping 'rust' - already installed ${NC}"
    fi
    ;;
  c)
    nvim_install_options
    ;;
  d) install_it "rg" ;;
  e) install_it "fd" ;;
  f) install_it "fzf" ;;
  q) exit 0 ;;
  esac
done

exit 0

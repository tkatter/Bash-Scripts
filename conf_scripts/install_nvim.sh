#!/usr/bin/bash

source "$(dirname "$0")/lib_utils.sh"

## Sets DETECTED_OS && DETECTED_ARCH
get_host_info

## Get fzf github-specific host tuple info
NVIM_OS=""
case "$DETECTED_OS" in
linux) NVIM_OS="linux" ;;
darwin) NVIM_OS="macos" ;;
windows) NVIM_OS="win64" ;;
*) error_msg "nvim: Unsupported OS for asset matching: $DETECTED_OS" "exit" ;;
esac

NVIM_ARCH=""
case "$DETECTED_ARCH" in
amd64) NVIM_ARCH="x86_64" ;;
arm64) NVIM_ARCH="arm64" ;;
386) NVIM_ARCH="386" ;;
*) error_msg "nvim: Unsupported ARCH for asset matching: $DETECTED_ARCH" "exit" ;;
esac

NVIM_OWNER="neovim"
NVIM_REPO="neovim"
TAG_NAME="v0.11.4"

SEARCH_PATTERN="${NVIM_OS}-${NVIM_ARCH}.tar.gz"

echo -e "${YELLOW}Looking for asset matching pattern: '${SEARCH_PATTERN}' for version '${TAG_NAME}'...${NC}"

API_URL="https://api.github.com/repos/${NVIM_OWNER}/${NVIM_REPO}/releases/tags/${TAG_NAME}"
DOWNLOAD_URL=$(curl -sL "$API_URL" |
  jq -r ".assets[] | select(.name | contains(\"${SEARCH_PATTERN}\")) | .browser_download_url")

if [[ -z "$DOWNLOAD_URL" ]]; then
  error_msg "Could not find a suitable release asset for ${OS}_${ARCH} and tag ${TAG_NAME}"
  ## Fallback to listing assets or providing more info
  curl -sL "$API_URL" | jq '.assets[] | .name'
  exit 1
fi

echo -e "${BLUE}Found download URL: $DOWNLOAD_URL${NC}"

FILE_NAME=$(basename "$DOWNLOAD_URL")
echo -e "${YELLOW}Downloading $FILE_NAME...${NC}"

cd $HOME
curl -sL -o "$FILE_NAME" "$DOWNLOAD_URL"

if [[ $? -eq 0 ]]; then
  echo -e "${BOLD}${GREEN}Download complete: $FILE_NAME${NC}"

  tar -xzf $FILE_NAME
  ## tar-ing results in a dir
  PKG_DIR=$(basename -s .tar.gz $FILE_NAME)
  rm -f $FILE_NAME

  sudo mv "$PKG_DIR" "$USR_BIN/"

  ## Create symlink
  if [[ ! -d "$LOCAL_BIN" ]]; then
    mkdir -p "$LOCAL_BIN"
  fi
  sudo ln -s "$USR_BIN/$PKG_DIR/bin/nvim" "$LOCAL_BIN/nvim"

  echo -e "${BOLD}${GREEN}'nvim' installation complete!${NC}"
else
  error_msg "Download failed." "exit"
fi

# https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.tar.gz

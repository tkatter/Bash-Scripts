#!/usr/bin/bash

source "$(dirname "$0")/lib_utils.sh"

## Sets DETECTED_OS && DETECTED_ARCH
get_host_info

## Get fzf github-specific host tuple info
FZF_OS=""
case "$DETECTED_OS" in
linux) FZF_OS="linux" ;;
darwin) FZF_OS="darwin" ;;
windows) FZF_OS="windows" ;;
*) error_msg "fzf: Unsupported OS for asset matching: $DETECTED_OS" "exit" ;;
esac

FZF_ARCH=""
case "$DETECTED_ARCH" in
amd64) FZF_ARCH="amd64" ;;
arm64) FZF_ARCH="arm64" ;;
386) FZF_ARCH="386" ;;
*) error_msg "fzf: Unsupported ARCH for asset matching: $DETECTED_ARCH" "exit" ;;
esac

FZF_OWNER="junegunn"
FZF_REPO="fzf"
TAG_NAME="v0.65.2"

## Strip 'v' prefix
VERSION=$(echo "$TAG_NAME" | sed 's/^v//')
SEARCH_PATTERN="${VERSION}-${FZF_OS}_${FZF_ARCH}"

echo -e "${YELLOW}Looking for asset matching pattern: '${SEARCH_PATTERN}' for version '${TAG_NAME}'...${NC}"

API_URL="https://api.github.com/repos/${FZF_OWNER}/${FZF_REPO}/releases/tags/${TAG_NAME}"
DOWNLOAD_URL=$(curl -sL "$API_URL" |
  jq -r ".assets[] | select(.name | contains(\"${SEARCH_PATTERN}\")) | .browser_download_url")

if [[ -z "$DOWNLOAD_URL" ]]; then
  error_msg "Could not find a suitable release asset for ${VERSION}-${OS}_${ARCH} and tag ${TAG_NAME}"
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

  tar -xzf $FILE_NAME && rm -f $FILE_NAME
  ## tar-ing results in a single binary file `fzf`
  sudo mv fzf "$USR_BIN/"

  ## Create symlink
  if [[ ! -d "$LOCAL_BIN" ]]; then
    mkdir -p "$LOCAL_BIN"
  fi
  sudo ln -s "$USR_BIN/fzf" "$LOCAL_BIN/fzf"
  echo -e "${BOLD}${GREEN}'fzf' installation complete!${NC}"
else
  error_msg "Download failed." "exit"
fi

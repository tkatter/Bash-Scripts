#!/usr/bin/bash

source "$(dirname "$0")/lib_utils.sh"

## Sets DETECTED_OS && DETECTED_ARCH
get_host_info

## Get fzf github-specific host tuple info
RG_OS=""
case "$DETECTED_OS" in
linux) RG_OS="unknown-linux" ;;
darwin) RG_OS="apple-darwin" ;;
windows) RG_OS="pc-windows" ;;
*) error_msg "ripgrep: Unsupported OS for asset matching: $DETECTED_OS" "exit" ;;
esac

RG_ARCH=""
case "$DETECTED_ARCH" in
amd64) RG_ARCH="amd64" ;;
arm64) RG_ARCH="aarch64" ;;
386) RG_ARCH="386" ;;
*) error_msg "ripgrep: Unsupported ARCH for asset matching: $DETECTED_ARCH" "exit" ;;
esac

RG_OWNER="BurntSushi"
RG_REPO="ripgrep"
## Ripgrep doesn't use v* tags
TAG_NAME="14.1.1"

## Right now this is just targeting the .deb file
SEARCH_PATTERN="${TAG_NAME}-1_${RG_ARCH}"

echo -e "${YELLOW}Looking for asset matching pattern: '${SEARCH_PATTERN}' for version '${TAG_NAME}'...${NC}"

API_URL="https://api.github.com/repos/${RG_OWNER}/${RG_REPO}/releases/tags/${TAG_NAME}"
DOWNLOAD_URL=$(curl -sL "$API_URL" |
  jq -r ".assets[] | select(.name | contains(\"${SEARCH_PATTERN}\") and endswith(\".deb\")) | .browser_download_url")

if [[ -z "$DOWNLOAD_URL" ]]; then
  error_msg "Could not find a suitable release asset for ${TAG_NAME}-${ARCH} and tag ${TAG_NAME}"
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

  echo -e "${YELLOW}Installing...${NC}"
  ## Install as local .deb package
  sudo apt install ./$FILE_NAME &>/dev/null && rm -f $FILE_NAME
  echo -e "${BOLD}${GREEN}'rg' installation complete!${NC}"
else
  error_msg "Download failed." "exit"
fi

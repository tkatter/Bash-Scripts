#!/usr/bin/bash

source "$(dirname "$0")/lib_utils.sh"

FD_OWNER="sharkdp"
FD_REPO="fd"
TAG_NAME="v10.3.0"

## Sets DETECTED_OS && DETECTED_ARCH
get_host_info

## Get fd github-specific host tuple info
FD_OS=""
case "$DETECTED_OS" in
linux) FD_OS="linux" ;;
darwin) FD_OS="apple-darwin" ;;
windows) FD_OS="win64" ;;
*) error_msg "fd: Unsupported OS for asset matching: $DETECTED_OS" "exit" ;;
esac

FD_ARCH=""
case "$DETECTED_ARCH" in
amd64) FD_ARCH="amd64" ;;
arm64) FD_ARCH="arm64" ;;
386) FD_ARCH="386" ;;
*) error_msg "fd: Unsupported ARCH for asset matching: $DETECTED_ARCH" "exit" ;;
esac

## Strip 'v' prefix
VERSION=$(echo "$TAG_NAME" | sed 's/^v//')
SEARCH_PATTERN="${VERSION}_${FD_ARCH}"

echo -e "${YELLOW}Looking for asset matching pattern: '${SEARCH_PATTERN}' for version '${TAG_NAME}'...${NC}"

API_URL="https://api.github.com/repos/${FD_OWNER}/${FD_REPO}/releases/tags/${TAG_NAME}"

## Download the .deb file - avoid the `musl` versions
DOWNLOAD_URL=$(curl -sL "$API_URL" |
  jq -r ".assets[] | select(.name | contains(\"${SEARCH_PATTERN}\")) | select(.name | contains(\"musl\") | not) | .browser_download_url")

if [[ -z "$DOWNLOAD_URL" ]]; then
  error_msg "Could not find a suitable release asset for ${VERSION}_${ARCH} and tag ${TAG_NAME}"
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
  echo -e "${BOLD}${GREEN}'fzf' installation complete!${NC}"
else
  error_msg "Download failed." "exit"
fi

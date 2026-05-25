#!/usr/bin/env bash
set -euo pipefail

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  TARGET="x86_64-unknown-linux-musl" ;;
    aarch64) TARGET="aarch64-unknown-linux-musl" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

LATEST=$(curl -fsSL https://api.github.com/repos/zellij-org/zellij/releases/latest | grep -oP '"tag_name": "\K[^"]+')
echo "Installing zellij ${LATEST} for ${TARGET}..."

curl -fsSL "https://github.com/zellij-org/zellij/releases/download/${LATEST}/zellij-${TARGET}.tar.gz" \
    | tar xz -C /usr/local/bin zellij

zellij --version
echo "zellij installed successfully."

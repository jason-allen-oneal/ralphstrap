#!/usr/bin/env bash
set -euo pipefail

# Simple installer to place ralphstrap on your PATH.
# Usage:
#   ./install.sh            # installs to ~/.local/bin/ralphstrap
#   TARGET_DIR=/usr/local/bin sudo ./install.sh   # alternative target

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/ralphstrap.sh"

if [[ ! -f "$SOURCE" ]]; then
  echo "ERROR: ralphstrap.sh not found next to install.sh" >&2
  exit 1
fi

# Default target:
# - regular user: ~/.local/bin
# - under sudo (no TARGET_DIR override): /usr/local/bin
if [[ -z "${TARGET_DIR:-}" ]]; then
  if [[ -n "${SUDO_USER:-}" ]]; then
    TARGET_DIR="/usr/local/bin"
  else
    TARGET_DIR="$HOME/.local/bin"
  fi
fi

TARGET_BIN="${TARGET_BIN:-$TARGET_DIR/ralphstrap}"

mkdir -p "$TARGET_DIR"
install -m 755 "$SOURCE" "$TARGET_BIN"

echo "Installed ralphstrap to: $TARGET_BIN"
echo "Ensure $TARGET_DIR is on your PATH to run ralphstrap from anywhere."

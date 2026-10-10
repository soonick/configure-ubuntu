#!/usr/bin/env bash

# Copies the GPG public key to the clipboard and opens GitHub to add it
# Run after user-run.sh: sh copy-gpg.sh

set -Eeuo pipefail

pubkey=~/.ssh/gpg.pub
if command -v wl-copy &> /dev/null; then
  wl-copy < "$pubkey"
elif command -v xclip &> /dev/null; then
  xclip -selection clipboard < "$pubkey"
else
  echo "wl-copy or xclip not found, copy $pubkey manually" >&2
  exit 1
fi
echo "GPG key copied to the clipboard"
xdg-open https://github.com/settings/gpg/new &> /dev/null || true
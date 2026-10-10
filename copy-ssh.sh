#!/usr/bin/env bash

# Copies the SSH public key to the clipboard and opens GitHub to add it
# Run after user-run.sh: sh copy-ssh.sh

set -Eeuo pipefail

pubkey=~/.ssh/github_rsa.pub
if command -v wl-copy &> /dev/null; then
  wl-copy < "$pubkey"
elif command -v xclip &> /dev/null; then
  xclip -selection clipboard < "$pubkey"
else
  echo "wl-copy or xclip not found, copy $pubkey manually" >&2
  exit 1
fi
echo "SSH key copied to the clipboard"
xdg-open https://github.com/settings/ssh/new &> /dev/null || true
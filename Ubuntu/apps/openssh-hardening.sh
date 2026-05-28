#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SNIPPET_SRC="$SCRIPT_DIR/../configs/sshd/99-homeserver.conf"
SNIPPET_DST="/etc/ssh/sshd_config.d/99-homeserver.conf"

if [[ ! -f "$SNIPPET_SRC" ]]; then
  echo "ERROR: Missing SSH config snippet at $SNIPPET_SRC" >&2
  exit 1
fi

if ! dpkg -s openssh-server >/dev/null 2>&1; then
  echo "Installing openssh-server..."
  sudo apt-get update
  sudo apt-get install -y openssh-server
fi

echo "Enabling SSH service..."
sudo systemctl enable --now ssh

if [[ ! -f "$HOME/.ssh/authorized_keys" ]] || [[ ! -s "$HOME/.ssh/authorized_keys" ]]; then
  echo "WARNING: ~/.ssh/authorized_keys is missing or empty."
  echo "Ensure your public key is installed before logging out of a remote session."
fi

echo "Installing SSH hardening snippet..."
sudo install -d -m 0755 /etc/ssh/sshd_config.d
sudo install -m 0644 "$SNIPPET_SRC" "$SNIPPET_DST"

echo "Validating sshd configuration..."
sudo sshd -t

echo "Reloading ssh..."
sudo systemctl reload ssh

echo "OpenSSH hardening applied."

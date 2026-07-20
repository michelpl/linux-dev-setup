#!/usr/bin/env bash
# Install Tailscale package and enable tailscaled. Does NOT run "tailscale up"
# (auth belongs to the homeserver repo via TS_AUTHKEY).
set -euo pipefail

if command -v tailscale >/dev/null 2>&1 && systemctl is-active --quiet tailscaled 2>/dev/null; then
  echo "Tailscale is already installed and tailscaled is active:"
  tailscale version
  exit 0
fi

echo "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo "Enabling tailscaled..."
sudo systemctl enable --now tailscaled

if ! command -v tailscale >/dev/null 2>&1; then
  echo "ERROR: tailscale CLI not found after installation." >&2
  exit 1
fi

if ! systemctl is-active --quiet tailscaled; then
  echo "ERROR: tailscaled is not active after enable." >&2
  exit 1
fi

echo "Tailscale package ready (not logged in yet — run homeserver ensure-tailscale / bootstrap):"
tailscale version

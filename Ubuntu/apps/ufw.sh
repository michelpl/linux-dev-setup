#!/usr/bin/env bash
set -euo pipefail

SSH_PORT="${SSH_PORT:-22}"

if ! command -v ufw >/dev/null 2>&1; then
  echo "Installing ufw..."
  sudo apt-get update
  sudo apt-get install -y ufw
fi

echo "Configuring UFW (SSH on port ${SSH_PORT})..."
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow "${SSH_PORT}/tcp" comment 'OpenSSH'
sudo ufw --force enable

sudo ufw status verbose
echo "UFW enabled."

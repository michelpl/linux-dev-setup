#!/usr/bin/env bash
set -euo pipefail

echo "Installing unattended-upgrades..."
sudo apt-get update
sudo apt-get install -y unattended-upgrades apt-listchanges

if [[ -f /etc/apt/apt.conf.d/20auto-upgrades ]]; then
  sudo tee /etc/apt/apt.conf.d/20auto-upgrades >/dev/null <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF
fi

sudo systemctl enable unattended-upgrades 2>/dev/null || true
echo "unattended-upgrades configured."

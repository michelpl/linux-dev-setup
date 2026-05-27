#!/usr/bin/env bash
set -euo pipefail

if ! command -v fail2ban-client >/dev/null 2>&1; then
  echo "Installing fail2ban..."
  sudo apt-get update
  sudo apt-get install -y fail2ban
fi

JAIL_LOCAL="/etc/fail2ban/jail.d/homelab.local"
if [[ ! -f "$JAIL_LOCAL" ]]; then
  echo "Creating fail2ban jail for sshd..."
  sudo tee "$JAIL_LOCAL" >/dev/null <<'EOF'
[sshd]
enabled = true
EOF
fi

sudo systemctl enable --now fail2ban
sudo fail2ban-client status sshd >/dev/null 2>&1 || true
echo "fail2ban is active."

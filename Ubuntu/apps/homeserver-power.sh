#!/usr/bin/env bash
set -euo pipefail

echo "Disabling system suspend and hibernate..."

# systemd-logind (works on Desktop and Server)
LOGIN_CONF="/etc/systemd/logind.conf"
sudo mkdir -p /etc/systemd/logind.conf.d
sudo tee /etc/systemd/logind.conf.d/homeserver.conf >/dev/null <<'EOF'
[Login]
HandleSuspendKey=ignore
HandleHibernateKey=ignore
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
IdleAction=ignore
EOF

if [[ -f "$LOGIN_CONF" ]]; then
  sudo sed -i 's/^#*HandleSuspendKey=.*/HandleSuspendKey=ignore/' "$LOGIN_CONF" 2>/dev/null || true
  sudo sed -i 's/^#*HandleHibernateKey=.*/HandleHibernateKey=ignore/' "$LOGIN_CONF" 2>/dev/null || true
fi

# GNOME power settings (Ubuntu Desktop)
if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing' 2>/dev/null || true
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing' 2>/dev/null || true
  gsettings set org.gnome.desktop.session idle-delay 0 2>/dev/null || true
fi

sudo systemctl restart systemd-logind 2>/dev/null || true
echo "Power management adjusted for always-on homeserver host use."

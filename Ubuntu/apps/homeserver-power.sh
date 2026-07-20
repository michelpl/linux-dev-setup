#!/usr/bin/env bash
# Always-on homeserver: block suspend/hibernate so the host stays reachable
# (Tailscale/SSH). Idempotent — safe to re-run via: ./setup.sh i homeserver-power
set -euo pipefail

echo "=== homeserver-power: always-on hardening ==="

ok() { echo "  [ok] $*"; }
fail() { echo "  [FAIL] $*" >&2; }

# --- 1. Mask sleep targets (blocks OS suspend even if a desktop app requests it) ---
echo "Masking sleep/suspend/hibernate targets..."
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
ok "systemd sleep targets masked"

# --- 2. logind drop-in ---
echo "Writing systemd-logind drop-in..."
sudo mkdir -p /etc/systemd/logind.conf.d
# Prefer 99- so it wins over other drop-ins; remove legacy filename if present.
sudo rm -f /etc/systemd/logind.conf.d/homeserver.conf
sudo tee /etc/systemd/logind.conf.d/99-homeserver-power.conf >/dev/null <<'EOF'
[Login]
HandleSuspendKey=ignore
HandleHibernateKey=ignore
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
HandlePowerKey=poweroff
IdleAction=ignore
EOF
ok "wrote /etc/systemd/logind.conf.d/99-homeserver-power.conf"

LOGIN_CONF="/etc/systemd/logind.conf"
if [[ -f "$LOGIN_CONF" ]]; then
  sudo sed -i 's/^#*HandleSuspendKey=.*/HandleSuspendKey=ignore/' "$LOGIN_CONF" 2>/dev/null || true
  sudo sed -i 's/^#*HandleHibernateKey=.*/HandleHibernateKey=ignore/' "$LOGIN_CONF" 2>/dev/null || true
  sudo sed -i 's/^#*IdleAction=.*/IdleAction=ignore/' "$LOGIN_CONF" 2>/dev/null || true
fi

sudo systemctl restart systemd-logind 2>/dev/null || true
ok "systemd-logind restarted"

# --- 3. System-wide GNOME policy (dconf) — Desktop / GDM ---
echo "Writing system-wide dconf power policy (no-op on Server without GNOME)..."
sudo mkdir -p /etc/dconf/db/local.d /etc/dconf/profile
if [[ ! -f /etc/dconf/profile/user ]]; then
  sudo tee /etc/dconf/profile/user >/dev/null <<'EOF'
user-db:user
system-db:local
EOF
fi
sudo tee /etc/dconf/db/local.d/00-homeserver-power >/dev/null <<'EOF'
[org/gnome/settings-daemon/plugins/power]
sleep-inactive-ac-type='nothing'
sleep-inactive-battery-type='nothing'
sleep-inactive-ac-timeout=0
sleep-inactive-battery-timeout=0
idle-dim=false
power-button-action='interactive'

[org/gnome/desktop/session]
idle-delay=uint32 0

[org/gnome/desktop/screensaver]
idle-activation-enabled=false
lock-enabled=false

[org/gnome/desktop/interface]
show-battery-percentage=false
EOF

if command -v dconf >/dev/null 2>&1; then
  sudo dconf update
  ok "dconf updated (/etc/dconf/db/local.d/00-homeserver-power)"
else
  ok "dconf CLI not installed — file written for when GNOME is present"
fi

# Per-user gsettings (installing user session)
if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing' 2>/dev/null || true
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing' 2>/dev/null || true
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0 2>/dev/null || true
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0 2>/dev/null || true
  gsettings set org.gnome.settings-daemon.plugins.power idle-dim false 2>/dev/null || true
  gsettings set org.gnome.desktop.session idle-delay 0 2>/dev/null || true
  gsettings set org.gnome.desktop.screensaver idle-activation-enabled false 2>/dev/null || true
  ok "gsettings applied for current user (best-effort)"
fi

# --- 4. Verification ---
echo ""
echo "=== Verification ==="
FAILED=0

for t in sleep.target suspend.target hibernate.target hybrid-sleep.target; do
  state="$(systemctl is-enabled "$t" 2>/dev/null || true)"
  if [[ "$state" == "masked" ]]; then
    ok "$t is masked"
  else
    fail "$t is '$state' (expected masked)"
    FAILED=1
  fi
done

if [[ -f /etc/systemd/logind.conf.d/99-homeserver-power.conf ]]; then
  ok "logind drop-in present"
else
  fail "logind drop-in missing"
  FAILED=1
fi

if [[ -f /etc/dconf/db/local.d/00-homeserver-power ]]; then
  ok "dconf power policy present"
else
  fail "dconf power policy missing"
  FAILED=1
fi

echo ""
if [[ "$FAILED" -ne 0 ]]; then
  echo "homeserver-power: completed with failures — review output above." >&2
  exit 1
fi

echo "homeserver-power: host is configured always-on (OS will not suspend/hibernate)."
echo "Note: a blank monitor is OK if Tailscale/SSH still work. Disable BIOS/UEFI Sleep/ErP manually if the machine still powers down."
echo "Black screen ≠ OS suspend; masked targets keep remote access alive."

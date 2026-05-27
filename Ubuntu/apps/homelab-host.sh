#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_app() {
  local name="$1"
  local script="$SCRIPT_DIR/${name}.sh"
  if [[ ! -f "$script" ]]; then
    echo "ERROR: Missing app script: $script" >&2
    exit 1
  fi
  echo ""
  echo "========== $name =========="
  bash "$script"
}

run_app docker
run_app openssh-hardening
run_app ufw
run_app fail2ban
run_app unattended-upgrades
run_app homelab-power

echo ""
echo "Homelab host preset completed."
echo "Next: clone the homeserver repo, run make init-local && make deploy"

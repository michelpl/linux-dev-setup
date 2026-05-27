#!/usr/bin/env bash
set -euo pipefail

if command -v ufw >/dev/null 2>&1; then
  sudo ufw --force disable || true
  echo "UFW disabled."
fi

#!/usr/bin/env bash
set -euo pipefail

if [[ -f /etc/os-release ]]; then
  # shellcheck disable=SC1091
  source /etc/os-release
else
  echo "❌ Could not detect the operating system." >&2
  exit 1
fi

if [[ "${ID:-}" != "ubuntu" ]]; then
  echo "❌ This script is only compatible with Ubuntu." >&2
  exit 1
fi

echo "🔄 Updating package list..."
sudo apt-get update

echo "📦 Installing git..."
sudo apt-get install -y git

echo "🐙 Installing GitHub CLI (gh)..."
if ! command -v gh >/dev/null 2>&1; then
  sudo apt-get install -y curl gpg
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg >/dev/null
  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update
fi
sudo apt-get install -y gh


if gh auth status >/dev/null 2>&1; then
  echo "🔐 GitHub CLI is already authenticated."
else
  echo "🔑 Starting GitHub CLI login..."
  gh auth login

  while ! gh auth status >/dev/null 2>&1; do
    echo "⚠️ Authentication not completed yet. Please finish login to continue."
    gh auth login
  done
fi

echo "📁 Ensuring ~/projects directory exists..."
mkdir -p "$HOME/projects"

if [[ -d "$HOME/projects/linux-dev-setup/.git" ]]; then
  echo "✅ Repository already exists at ~/projects/linux-dev-setup."
else
  echo "📥 Cloning michelpl/linux-dev-setup into ~/projects..."
  (
    cd "$HOME/projects"
    gh repo clone michelpl/linux-dev-setup
  )
fi

echo "✅ Setup completed successfully!"

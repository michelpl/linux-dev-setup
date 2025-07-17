#!/bin/bash
set -e

echo "🗑️ Uninstalling GitHub CLI..."

sudo apt remove --purge -y gh
sudo rm -f /etc/apt/sources.list.d/github-cli.list
sudo rm -f /usr/share/keyrings/githubcli-archive-keyring.gpg

echo "✅ GitHub CLI removed."

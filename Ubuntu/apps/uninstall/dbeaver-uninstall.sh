#!/bin/bash
set -e

echo "🗑️ Uninstalling DBeaver CE..."

sudo apt-get remove --purge -y dbeaver-ce
sudo apt-get autoremove -y

echo "✅ DBeaver CE removed."

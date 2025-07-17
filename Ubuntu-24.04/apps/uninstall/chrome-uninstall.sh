#!/bin/bash
set -e

echo "🗑️ Uninstalling Google Chrome..."

sudo apt-get remove --purge -y google-chrome-stable
sudo apt-get autoremove -y

echo "✅ Google Chrome removed."

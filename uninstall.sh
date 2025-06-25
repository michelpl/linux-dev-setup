#!/bin/bash

set -e

# Resolve caminho real mesmo via symlink
SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
APPS_DIR="$SCRIPT_DIR/apps"
UNINSTALL_DIR="$APPS_DIR/uninstall"
LOG_FILE="$SCRIPT_DIR/install.log"

# Verifica se whiptail está instalado
if ! command -v whiptail &> /dev/null; then
    echo "❌ 'whiptail' not found. Install with: sudo apt install whiptail"
    exit 1
fi

# Remove symlinks globais se existirem
if [ -L "/usr/local/bin/setup" ]; then
    echo "❌ Removing global symlink: /usr/local/bin/setup"
    sudo rm /usr/local/bin/setup
    echo "$(date '+%Y-%m-%d %H:%M:%S') - removed global symlink for setup.sh" >> "$LOG_FILE"
fi

if [ -L "/usr/local/bin/setup-uninstall" ]; then
    echo "❌ Removing global symlink: /usr/local/bin/setup-uninstall"
    sudo rm /usr/local/bin/setup-uninstall
    echo "$(date '+%Y-%m-%d %H:%M:%S') - removed global symlink for uninstall.sh" >> "$LOG_FILE"
fi

# Monta menu com apps disponíveis para desinstalar
MENU_ITEMS=()
if [ -d "$UNINSTALL_DIR" ]; then
    for file in "$UNINSTALL_DIR"/*-uninstall.sh; do
        app_name=$(basename "$file" -uninstall.sh)
        MENU_ITEMS+=("$app_name" "$app_name uninstall" OFF)
    done
else
    echo "❌ Directory '$UNINSTALL_DIR' not found!"
    exit 1
fi

CHOICES=$(whiptail --title "Uninstall Applications" --checklist \
"Select apps to uninstall" 20 78 12 \
"${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3)

clear
echo "You selected to uninstall: $CHOICES"

for choice in $CHOICES; do
    choice=$(echo "$choice" | tr -d '"')
    script="$UNINSTALL_DIR/$choice-uninstall.sh"
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    if [ -f "$script" ]; then
        echo "🗑️ Uninstalling $choice..."
        if bash "$script"; then
            echo "$TIMESTAMP - uninstalled $choice" >> "$LOG_FILE"
        else
            echo "$TIMESTAMP - FAILED to uninstall $choice" >> "$LOG_FILE"
        fi
    else
        echo "⚠️ Uninstall script not found: $script"
        echo "$TIMESTAMP - FAILED to uninstall $choice (not found)" >> "$LOG_FILE"
    fi
done

echo ""
echo "✅ All selected apps have been uninstalled."

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

APPS_DIR="$SCRIPT_DIR/apps"
UNINSTALL_DIR="$APPS_DIR/uninstall"
LOG_FILE="$SCRIPT_DIR/install.log"

# ------------------ INSTALAÇÃO DIRETA POR PARÂMETRO ------------------
if [ "$1" == "install" ] && [ $# -eq 2 ]; then
    APP_SCRIPT="$APPS_DIR/$2.sh"
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    if [ -f "$APP_SCRIPT" ]; then
        echo "⚙️ Installing $2..."
        sudo apt update && sudo apt upgrade -y
        if bash "$APP_SCRIPT"; then
            echo "$TIMESTAMP - installed $2 (direct)" >> "$LOG_FILE"
            echo "✅ $2 installed successfully."
        else
            echo "$TIMESTAMP - FAILED to install $2 (direct)" >> "$LOG_FILE"
            echo "❌ Failed to install $2."
        fi
        exit 0
    else
        echo "❌ App script not found: $APP_SCRIPT"
        exit 1
    fi
fi

# ------------------ DIRECT INSTALL BY PARAMETER (NEW SHORT SYNTAX) ------------------
if [ "$1" == "i" ] && [ $# -eq 2 ]; then
    APP_SCRIPT="$APPS_DIR/$2.sh"
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    if [ -f "$APP_SCRIPT" ]; then
        echo "⚙️ Installing $2..."
        sudo apt update && sudo apt upgrade -y
        if bash "$APP_SCRIPT"; then
            echo "$TIMESTAMP - installed $2 (direct)" >> "$LOG_FILE"
            echo "✅ $2 installed successfully."
        else
            echo "$TIMESTAMP - FAILED to install $2 (direct)" >> "$LOG_FILE"
            echo "❌ Failed to install $2."
        fi
        exit 0
    else
        echo "❌ App script not found: $APP_SCRIPT"
        exit 1
    fi
fi

# ------------------ DESINSTALAÇÃO ------------------

if [ "$1" == "uninstall" ]; then
  echo "🧼 Entering uninstall mode..."

  if ! command -v whiptail &> /dev/null; then
      echo "❌ 'whiptail' not found. Install with: sudo apt install whiptail"
      exit 1
  fi

  MENU_ITEMS=()
  MENU_ITEMS+=("remove-global" "Remove global access to 'setup'" OFF)

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
  "Select apps to uninstall and/or remove global access" 20 78 14 \
  "${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3)

  clear
  echo "You selected: $CHOICES"

  for choice in $CHOICES; do
      choice=$(echo "$choice" | tr -d '"')
      TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

      if [ "$choice" == "remove-global" ]; then
          if [ -L "/usr/local/bin/setup" ]; then
              echo "❌ Removing global symlink: /usr/local/bin/setup"
              sudo rm /usr/local/bin/setup
              echo "$TIMESTAMP - removed global symlink" >> "$LOG_FILE"
          else
              echo "ℹ️ Global symlink not found."
          fi
          continue
      fi

      script="$UNINSTALL_DIR/$choice-uninstall.sh"
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
  echo "✅ Uninstall completed."
  exit 0
fi

# ------------------ DIRECT UNINSTALL BY PARAMETER (NEW SHORT SYNTAX) ------------------
if [ "$1" == "u" ] && [ $# -eq 2 ]; then
    read -p "Are you sure you want to uninstall $2? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Uninstall cancelled."
        exit 0
    fi
    script="$UNINSTALL_DIR/$2-uninstall.sh"
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    if [ -f "$script" ]; then
        echo "🗑️ Uninstalling $2..."
        if bash "$script"; then
            echo "$TIMESTAMP - uninstalled $2 (direct)" >> "$LOG_FILE"
            echo "✅ $2 uninstalled successfully."
        else
            echo "$TIMESTAMP - FAILED to uninstall $2 (direct)" >> "$LOG_FILE"
            echo "❌ Failed to uninstall $2."
        fi
        exit 0
    else
        echo "⚠️ Uninstall script not found: $script"
        echo "$TIMESTAMP - FAILED to uninstall $2 (not found)" >> "$LOG_FILE"
        exit 1
    fi
fi

# ------------------ INSTALAÇÃO ------------------

if [ ! -d "$APPS_DIR" ]; then
    echo "❌ Directory '$APPS_DIR' not found!"
    exit 1
fi

MENU_ITEMS=()
MENU_ITEMS+=("global" "Make this script global" OFF)
MENU_ITEMS+=("uninstall" "Go to the uninstall menu" OFF)

for file in "$APPS_DIR"/*.sh; do
    app_name=$(basename "$file" .sh)
    MENU_ITEMS+=("$app_name" "$app_name setup" OFF)
done

CHOICES=$(whiptail --title "Ubuntu Setup" --checklist \
"Choose applications to install using [SPACE] to select and [ENTER] to confirm" 20 78 16 \
"${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3)

clear
echo "You selected: $CHOICES"

# Detecta se há apps reais (não "global" ou "uninstall")
INSTALL_CHOICES=()
for choice in $CHOICES; do
    plain=$(echo "$choice" | tr -d '"')
    if [ "$plain" != "global" ] && [ "$plain" != "uninstall" ]; then
        INSTALL_CHOICES+=("$plain")
    fi
done

# Atualiza sistema apenas se houver apps reais a instalar
if [ ${#INSTALL_CHOICES[@]} -gt 0 ]; then
    echo "🔄 Updating system..."
    sudo apt update && sudo apt upgrade -y
fi

# Processa escolhas
for choice in $CHOICES; do
    choice=$(echo "$choice" | tr -d '"')
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    if [ "$choice" = "global" ]; then
        echo "🌍 Making setup.sh globally executable..."
        sudo ln -sf "$SCRIPT_DIR/setup.sh" /usr/local/bin/setup
        echo "✅ setup.sh is now available as: setup"
        echo "ℹ️ To uninstall apps later, run: setup uninstall"
        echo "$TIMESTAMP - setup.sh made globally available" >> "$LOG_FILE"

        if [ "$SHELL" = "/bin/zsh" ] && [ -f "$HOME/.zshrc" ]; then
            echo "🔁 Reloading ~/.zshrc..."
            source "$HOME/.zshrc"
        fi
        continue
    fi

    if [ "$choice" = "uninstall" ]; then
        echo "📦 Redirecting to uninstall menu..."
        bash "$SCRIPT_DIR/setup.sh" uninstall
        exit 0
    fi

    script="$APPS_DIR/$choice.sh"
    if [ -f "$script" ]; then
        echo "⚙️ Running $choice setup..."
        if bash "$script"; then
            echo "$TIMESTAMP - installed $choice" >> "$LOG_FILE"
        else
            echo "$TIMESTAMP - FAILED to install $choice" >> "$LOG_FILE"
        fi
    else
        echo "⚠️ Script not found: $script"
        echo "$TIMESTAMP - FAILED to install $choice (not found)" >> "$LOG_FILE"
    fi
done

echo ""
echo "✅ All selected setups finished."

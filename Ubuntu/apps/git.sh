#!/bin/bash

sudo apt install -y git

GIT_NAME=$(whiptail --title "Git Config" --inputbox "Enter your Git user.name:" 10 60 3>&1 1>&2 2>&3)
GIT_EMAIL=$(whiptail --title "Git Config" --inputbox "Enter your Git user.email:" 10 60 3>&1 1>&2 2>&3)

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

echo "✅ Git installed and configured."

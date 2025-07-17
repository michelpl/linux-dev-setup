# Contributing to Linux Dev Setup

Thank you for your interest in contributing! 🎉

## About this Project

All install and uninstall scripts are tested and maintained for Ubuntu 24.04 LTS. Please ensure your contributions are compatible with this version.

If you want to contribute scripts for another OS/version, create a new folder named after the OS and version you tested (e.g., `Ubuntu-22.04`, `Fedora-39`, `Debian-12`). Follow the same structure and conventions as the existing folders.

## How to Contribute

1. **Fork the repository** and create your branch from `main`.
2. **Add a new app:**
   - Create an install script in `apps/` (e.g., `apps/mytool.sh`).
   - (Optional) Create a matching uninstall script in `apps/uninstall/` (e.g., `apps/uninstall/mytool-uninstall.sh`).
   - Your app will appear automatically in the setup and uninstall menus.
3. **Improve scripts or documentation:**
   - Feel free to refactor, fix bugs, or improve the README/docs.
4. **Open a Pull Request** with a clear description of your changes.

## Guidelines

- Keep scripts modular and in English.
- Test your scripts on Ubuntu 24.04+.
- Use clear, descriptive commit messages.
- If your script requires extra dependencies, handle their installation in the script.
- For questions or suggestions, open an issue.

Happy hacking! 🚀

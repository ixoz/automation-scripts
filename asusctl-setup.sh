#!/bin/bash
REPO_DIR="$HOME/asusctl"
BINARY_NAME="rog-control-center"
INSTALL_PATH="/usr/local/bin/$BINARY_NAME"
DESKTOP_FILE="$HOME/.local/share/applications/$BINARY_NAME.desktop"

function install_deps() {
  echo "Installing required packages..."
  if command -v apt >/dev/null; then
    sudo apt update
    sudo apt install -y build-essential git libgtk-3-dev libssl-dev pkg-config curl
  else
    echo "Please install build dependencies manually (no apt detected)"
  fi

  if ! command -v cargo >/dev/null; then
    echo "Installing Rust toolchain..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
  else
    echo "Rust already installed."
  fi
}

function clone_or_update_repo() {
  if [ -d "$REPO_DIR" ]; then
    echo "Updating existing asusctl repo..."
    cd "$REPO_DIR" || exit
    git pull
  else
    echo "Cloning asusctl repo..."
    git clone https://gitlab.com/asus-linux/asusctl.git "$REPO_DIR"
  fi
}

function build_rog_control_center() {
  echo "Building rog-control-center with X11 support..."
  cd "$REPO_DIR" || exit
  cargo build --release --features x11 -p rog-control-center
  if [ $? -ne 0 ]; then
    echo "Build failed! Exiting."
    exit 1
  fi
  echo "Build successful."
}

function install_binary() {
  echo "Installing binary to $INSTALL_PATH ..."
  cp "$REPO_DIR/target/release/$BINARY_NAME" "$INSTALL_PATH"
  chmod +x "$INSTALL_PATH"
  echo "Installed."
}

function create_desktop_entry() {
  echo "Creating desktop entry at $DESKTOP_FILE ..."
  mkdir -p "$(dirname "$DESKTOP_FILE")"
  cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=ROG Control Center
Comment=ASUS rog-control-center GUI
Exec=$INSTALL_PATH
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=Utility;System;
EOF
  echo "Desktop entry created."
  echo "You may need to run 'update-desktop-database' or log out/in for it to appear in menus."
}

function menu() {
  while true; do
    echo
    echo "=== ASUS ROG Control Center Setup ==="
    echo "1) Install build environment and Rust"
    echo "2) Clone or update asusctl repository"
    echo "3) Build rog-control-center with X11 support"
    echo "4) Install rog-control-center binary"
    echo "5) Create desktop shortcut"
    echo "6) Build & install all steps (1 to 5)"
    echo "0) Exit"
    read -rp "Choose an option: " choice
    case $choice in
      1) install_deps ;;
      2) clone_or_update_repo ;;
      3) build_rog_control_center ;;
      4) install_binary ;;
      5) create_desktop_entry ;;
      6) install_deps; clone_or_update_repo; build_rog_control_center; install_binary; create_desktop_entry ;;
      0) echo "Exiting."; exit 0 ;;
      *) echo "Invalid option." ;;
    esac
  done
}

menu

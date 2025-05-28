#!/bin/bash

# Update and upgrade the system
sudo apt update
sudo apt upgrade -y

# Install dependencies for adding repos
sudo apt install -y software-properties-common apt-transport-https wget

# Add Microsoft GPG key and repo for VS Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'

# Update again to include VS Code repo
sudo apt update

# Install VS Code
sudo apt install -y code

# Install fastfetch, gparted, and gedit
sudo apt install -y fastfetch gparted gedit

# Clean up
rm microsoft.gpg

echo "Update, upgrade, and installations complete."

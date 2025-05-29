#!/bin/bash

# Set up GitHub global configuration for user "ixoz"

git config --global user.email "148843416+ixoz@users.noreply.github.com"
git config --global user.name "ixoz"

# Set default editor to nano
git config --global core.editor "nano"

# Enable command autocorrect with 1 second delay
git config --global help.autocorrect 1

echo "GitHub configuration successfully."

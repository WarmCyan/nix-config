#!/usr/bin/env bash

# TODO: make this curlable/check if the repo is downloaded or not and do so if
# not

# https://nixos.org/download.html#nix-install-linux

# single user installation:
echo "Downloading and installing nix..."
sh <(curl -L https://nixos.org/nix/install) --no-daemon

echo "Setting up flakes..."
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

bash -lic "nix-env --set-flag priority 4 nix"
bash -lic "nix shell . -c bootstrap $1"

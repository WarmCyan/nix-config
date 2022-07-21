#!/bin/bash
set +x

sudo rm -rfd /nix
rm -rfd ~/.nix-profile

tail ~/.profile -n +2 | echo > ~/.profile

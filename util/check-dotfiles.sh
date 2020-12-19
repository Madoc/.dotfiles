#!/usr/bin/env bash
#
# Checks all files in the home directory that start with a dot. Reports unexpected files. Run this regularly if you
# want to keep your home directory tidy.

"$HOME/.dotfiles/util/check-dotfiles" "$HOME/.dotfiles/config/dotfile-whitelist.txt"

#!/usr/bin/env bash
#
# Ensures that all needed Zsh plugins are installed, or clones them if not.

[[ -e "$HOME/.oh-my-zsh/custom/plugins/command-time" ]] || git clone "https://github.com/popstas/zsh-command-time.git" "$HOME/.oh-my-zsh/custom/plugins/command-time"

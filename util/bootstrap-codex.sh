#!/usr/bin/env bash
#
# Installs or updates the Codex CLI into the user-local npm prefix.

set -euo pipefail

source "$HOME/.dotfiles/scripts/host_common"
source "$HOME/.dotfiles/scripts/env_common"

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is not installed. Install node/npm first." >&2
  exit 1
fi

mkdir -p "$DOTFILES_NPM_PREFIX"
NPM_CONFIG_PREFIX="$DOTFILES_NPM_PREFIX" npm install -g "npm@$DOTFILES_DEFAULT_NPM_VERSION"
NPM_CONFIG_PREFIX="$DOTFILES_NPM_PREFIX" npm install -g @openai/codex

#!/usr/bin/env bash
#
# Installs the baseline command line tools expected by the dotfiles on macOS.

set -euo pipefail

source "$HOME/.dotfiles/scripts/host_common"
source "$HOME/.dotfiles/scripts/env_common"

ensure_sdkman_config() {
  local config_file="$HOME/.sdkman/etc/config"
  mkdir -p "$(dirname "$config_file")"

  if [[ ! -f "$config_file" ]]; then
    : > "$config_file"
  fi

  if grep -q '^sdkman_auto_env=' "$config_file"; then
    sed -i.bak 's/^sdkman_auto_env=.*/sdkman_auto_env=true/' "$config_file"
  else
    printf '\nsdkman_auto_env=true\n' >> "$config_file"
  fi

  if grep -q '^sdkman_native_enable=' "$config_file"; then
    sed -i.bak 's/^sdkman_native_enable=.*/sdkman_native_enable=false/' "$config_file"
  else
    printf 'sdkman_native_enable=false\n' >> "$config_file"
  fi
}

run_sdk() {
  local had_nounset=0
  [[ $- == *u* ]] && had_nounset=1
  set +u
  sdk "$@"
  local rc=$?
  (( had_nounset )) && set -u
  return $rc
}

dotfiles_is_macos || {
  echo "bootstrap-macos.sh is only meant for macOS." >&2
  exit 1
}

command -v brew >/dev/null || bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

command -v asdf >/dev/null || brew install asdf
command -v cs >/dev/null || { brew install coursier/formulas/coursier ; cs setup; }
command -v dateconv >/dev/null || brew install dateutils
command -v emacs >/dev/null || brew install emacs
command -v gh >/dev/null || brew install gh
command -v go >/dev/null || brew install go
command -v htop >/dev/null || brew install htop
command -v lazygit >/dev/null || brew install lazygit
command -v neovide >/dev/null || brew install --cask neovide
command -v nvim >/dev/null || brew install neovim
command -v nvm >/dev/null || { { brew rm node || true; } ; { brew rm npm || true; } ; brew install nvm ; mkdir -p "${HOME}/.config/nvm"; }
command -v octave >/dev/null || brew install octave
command -v rg >/dev/null || brew install ripgrep
command -v rustc >/dev/null || { curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh; }
if [[ ! -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  bash -c "$(curl -fsSL https://get.sdkman.io)"
fi

ensure_sdkman_config

if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  set +u
  source "$HOME/.sdkman/bin/sdkman-init.sh"
  set -u
fi

if typeset -f sdk >/dev/null 2>&1; then
  if [[ ! -d "$HOME/.sdkman/candidates/java/$DOTFILES_DEFAULT_JAVA_VERSION" ]]; then
    run_sdk install java "$DOTFILES_DEFAULT_JAVA_VERSION"
  fi
  run_sdk default java "$DOTFILES_DEFAULT_JAVA_VERSION"
fi

command -v sbt >/dev/null || brew install sbt
command -v starship >/dev/null || brew install starship
command -v tmux >/dev/null || brew install tmux
command -v wget >/dev/null || brew install wget

#!/usr/bin/env bash
#
# Installs the imperative cross-platform JVM layer expected by the dotfiles on NixOS.

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
    sed -i 's/^sdkman_auto_env=.*/sdkman_auto_env=true/' "$config_file"
  else
    printf '
sdkman_auto_env=true
' >> "$config_file"
  fi

  if grep -q '^sdkman_native_enable=' "$config_file"; then
    sed -i 's/^sdkman_native_enable=.*/sdkman_native_enable=false/' "$config_file"
  else
    printf 'sdkman_native_enable=false
' >> "$config_file"
  fi
}

dotfiles_is_nixos || {
  echo "bootstrap-nixos.sh is only meant for NixOS." >&2
  exit 1
}

command -v sdk >/dev/null || bash -c "$(curl -fsSL https://get.sdkman.io)"
ensure_sdkman_config
if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  set +u
  source "$HOME/.sdkman/bin/sdkman-init.sh"
  set -u
fi

if command -v sdk >/dev/null; then
  sdk install java "$DOTFILES_DEFAULT_JAVA_VERSION" || true
  sdk default java "$DOTFILES_DEFAULT_JAVA_VERSION"
fi

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
    printf '\nsdkman_auto_env=true\n' >> "$config_file"
  fi

  if grep -q '^sdkman_native_enable=' "$config_file"; then
    sed -i 's/^sdkman_native_enable=.*/sdkman_native_enable=false/' "$config_file"
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

dotfiles_is_nixos || {
  echo "bootstrap-nixos.sh is only meant for NixOS." >&2
  exit 1
}

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

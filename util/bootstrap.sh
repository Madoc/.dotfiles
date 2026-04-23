#!/usr/bin/env bash
#
# Host-aware bootstrap entry point for installing baseline dependencies.

set -euo pipefail

source "$HOME/.dotfiles/scripts/host_common"

case "${DOTFILES_PLATFORM}" in
  macos)
    exec "$HOME/.dotfiles/util/bootstrap-macos.sh"
    ;;
  nixos)
    exec "$HOME/.dotfiles/util/bootstrap-nixos.sh"
    ;;
  linux)
    cat <<'EOF'
No generic Linux bootstrap is defined yet.
Add a dedicated bootstrap script before using this path.
EOF
    ;;
  *)
    echo "Unsupported platform: ${DOTFILES_PLATFORM}" >&2
    exit 1
    ;;
esac

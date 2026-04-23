#!/usr/bin/env bash
#
# Checks all files in the home directory that start with a dot. Reports unexpected files. Run this regularly if you
# want to keep your home directory tidy.

set -euo pipefail

config_file="$HOME/.config/dotfiles/whitelist.txt"
manifest_dir="$HOME/.dotfiles/util/code/check_dotfiles"
manifest="$manifest_dir/Cargo.toml"
cached_binary="$HOME/.dotfiles/util/check-dotfiles"
release_binary="$manifest_dir/target/release/check_dotfiles"

binary_is_stale() {
  [[ -x "$cached_binary" ]] || return 0
  [[ "$manifest" -nt "$cached_binary" ]] && return 0
  [[ "$manifest_dir/Cargo.lock" -nt "$cached_binary" ]] && return 0
  find "$manifest_dir/src" -type f -newer "$cached_binary" -print -quit | grep -q .
}

ensure_binary() {
  if ! binary_is_stale; then
    return 0
  fi

  command -v cargo >/dev/null 2>&1 || return 1
  cargo build --quiet --release --manifest-path "$manifest" || return 1
  cp "$release_binary" "$cached_binary" || return 1
  chmod +x "$cached_binary" || return 1
}

if ensure_binary; then
  exec "$cached_binary" "$config_file"
fi

echo "Skipping check-dotfiles: no cached binary and no cargo toolchain found." >&2
exit 0

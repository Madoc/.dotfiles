#!/usr/bin/env bash
#
# Installs or updates the dotfile links in the home directory.
#
# Basically just iterates over all files under ~/.dotfiles/linked-home, and creates symlinks to them in the home
# directory, just with a dot prepended. Links that already exist will be left unchanged, non-existing files will be
# created, and in case of unexpected files, the user will be asked if they should be overwritten.

source "${HOME}/.dotfiles/scripts/host_common"

# Creates the link if it does not exist. If there is a different link or file at the target, the user will be asked
# if it should be overwritten.
ensure_link() {
  source_file="$1"
  target_file="$2"

  source_link=$(realpath "${source_file}")
  target_link=$(readlink "${target_file}")
  if [[ -e "$target_file" && "${source_link}" == "${target_link}" ]]; then
    true
  else
    ln -si "${source_file}" "${target_file}"
  fi
}

realpath() {
    path=`eval echo "$1"`
    folder=$(dirname "$path")
    echo $(cd "$folder"; pwd)/$(basename "$path");
}

apply_platform_overrides() {
  overlay_root="${HOME}/.dotfiles/linked-home-platforms/${DOTFILES_PLATFORM}"
  [[ -d "${overlay_root}" ]] || return 0

  find "${overlay_root}" -type f | while read -r overlay_file; do
    relative_path="${overlay_file#${overlay_root}/}"
    target_file="${HOME}/.${relative_path}"
    mkdir -p "$(dirname "${target_file}")"
    ensure_link "${overlay_file}" "${target_file}"
  done
}

custom_links() {
  if dotfiles_is_macos && [[ -d "${HOME}/bin" ]] && [[ -x "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ]]; then
    ensure_link "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" "${HOME}/bin/subl"
  fi
}

main() {
  for linked_file in "${HOME}/.dotfiles/linked-home/"*; do
    base_name=$(basename "${linked_file}")
    if [[ "${base_name}" != "README.md" ]]; then
      ensure_link "${linked_file}" "${HOME}/.${base_name}"
    fi
  done

  custom_links
  apply_platform_overrides

  "${HOME}/.dotfiles/util/check-dotfiles.sh"
}

main

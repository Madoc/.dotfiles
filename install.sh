#!/usr/bin/env bash
#
# Installs or updates the dotfile links in the home directory.
#
# Basically just iterates over all files under ~/.dotfiles/linked-home, and creates symlinks to them in the home
# directory, just with a dot prepended. Links that already exist will be left unchanged, non-existing files will be
# created, and in case of unexpected files, the user will be asked if they should be overwritten.

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

custom_links() {
  [[ -d "${HOME}/bin" ]] && ensure_link "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" "${HOME}/bin/subl"
}

main() {
  for linked_file in "${HOME}/.dotfiles/linked-home/"*; do
    base_name=$(basename "${linked_file}")
    if [[ "${base_name}" != "README.md" ]]; then
      ensure_link "${linked_file}" "${HOME}/.${base_name}"
    fi
  done

  custom_links

  "${HOME}/.dotfiles/util/check-dotfiles.sh"
}

main

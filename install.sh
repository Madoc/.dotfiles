#!/usr/bin/env bash
#
# Installs or updates the dotfile links in the home directory.
#
# Basically just iterates over all files under ~/.dotfiles/linked-home, and creates symlinks to them in the home
# directory, just with a dot prepended. Links that already exist will be left unchanged, non-existing files will be
# created, and in case of unexpected files, the user will be asked if they should be overwritten.

source "${HOME}/.dotfiles/scripts/host_common"

# Creates the link if it does not exist. If there is a different link or file at the target, the user will be asked
# if it should be overwritten. Existing directories are merged recursively so that trees like ~/.config can keep
# their directory shape while individual files inside still come from the dotfiles repo.
ensure_link() {
  local source_file="$1"
  local target_file="$2"
  local source_link
  local target_link
  local target_realpath=""
  local source_parent_realpath
  local target_parent_realpath=""
  local child_source
  local child_name
  local -a child_sources=()

  source_link=$(realpath "${source_file}")
  source_parent_realpath=$(realpath "$(dirname "${source_file}")")
  target_link=$(readlink "${target_file}")

  if [[ -e "$target_file" ]]; then
    target_realpath=$(realpath "${target_file}")
    if [[ "$source_link" == "$target_realpath" ]]; then
      return 0
    fi
  fi

  if [[ -e "$(dirname "$target_file")" ]]; then
    target_parent_realpath=$(realpath "$(dirname "$target_file")")
    if [[ "$source_parent_realpath" == "$target_parent_realpath" && "$(basename "$source_file")" == "$(basename "$target_file")" ]]; then
      return 0
    fi
  fi

  if [[ -d "$source_file" && -d "$target_file" && ! -L "$target_file" ]]; then
    while IFS= read -r -d '' child_source; do
      child_sources+=("$child_source")
    done < <(find "$source_file" -mindepth 1 -maxdepth 1 -print0)

    for child_source in "${child_sources[@]}"; do
      child_name=$(basename "$child_source")
      ensure_link "$child_source" "$target_file/$child_name"
    done
    return 0
  fi

  if [[ -e "$target_file" && "$source_link" == "$target_link" ]]; then
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

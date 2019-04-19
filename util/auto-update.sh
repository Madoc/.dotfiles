#!/usr/bin/env bash
#
# Checks if the dotfiles directory has a pending update. Will only do a Git fetch once per day.

UPDATE_TIMESTAMP_FILE="${HOME}/.dotfiles/.auto-update-timestamp~"

main() {
  if [[ ! -f "${UPDATE_TIMESTAMP_FILE}" ]]; then
    perform_check "true"
  elif test `find "${UPDATE_TIMESTAMP_FILE}" -mmin +1440`; then
    perform_check "true"
  else
    perform_check "false"
  fi
}

perform_check() {
  local do_fetch="$1"
  if [[ "$do_fetch" == "true" ]]; then
    touch "${UPDATE_TIMESTAMP_FILE}"
    echo "Checking ~/.dotfiles for updates."
  fi
  "${HOME}/.dotfiles/util/check-update.sh" "${HOME}/.dotfiles" "$do_fetch"
}

main

#!/usr/bin/env bash
#
# Checks if the dotfiles directory has a pending update. Will only do this check once per day.

UPDATE_TIMESTAMP_FILE="${HOME}/.dotfiles/.auto-update-timestamp~"

main() {
  if [[ ! -f "${UPDATE_TIMESTAMP_FILE}" ]]; then
    perform_check
  elif test `find "${UPDATE_TIMESTAMP_FILE}" -mmin +1440`; then
    perform_check
  fi
}

perform_check() {
  touch "${UPDATE_TIMESTAMP_FILE}"
  echo "Checking ~/.dotfiles for updates."
  "${HOME}/.dotfiles/util/check-update.sh" "${HOME}/.dotfiles"
}

main

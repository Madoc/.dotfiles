#!/usr/bin/env bash
#
# Prints a message if the repo needs to be updated or has local changes.
# The repo directory needs to be passed in as first argument.
# The second argument is either `true` or `false`, determining if a `git fetch` should be done.

REPO_DIRECTORY="$1"
DO_FETCH="$2"

check_for_updates() {
  cd "${REPO_DIRECTORY}" &&\
  local local_ref=$(git rev-parse @ 2>/dev/null) &&\
  local remote_ref=$(git rev-parse '@{u}' 2>/dev/null) &&\
  local base_ref=$(git merge-base @ '@{u}' 2>/dev/null) &&\
  print_update_message "${local_ref}" "${remote_ref}" "${base_ref}" &&\
  cd - >/dev/null
}

fetch() {
  cd "${REPO_DIRECTORY}" &&\
  git fetch >/dev/null &&\
  cd - >/dev/null
}

main() {
  validate_parameters
  if [[ "$DO_FETCH" == "true" ]]; then
    fetch && check_for_updates
  else
    check_for_updates
  fi
}

print_update_message() {
  local local_ref="$1"
  local remote_ref="$2"
  local base_ref="$3"
  if [[ "${local_ref}" == "${remote_ref}" ]]; then
    true # up-to-date
  elif [[ "${local_ref}" == "${base_ref}" ]]; then
    echo "${REPO_DIRECTORY}: Remote changes found. Please pull the changes:"
    echo ""
    echo "    cd \"${REPO_DIRECTORY}\" && git pull && ./install.sh && cd -"
    echo ""
  elif [[ "${remote_ref}" == "${base_ref}" ]]; then
    echo "${REPO_DIRECTORY}: Local changes found. Do not forget to push them."
  fi
}

validate_parameters() {
  if [[ "${REPO_DIRECTORY}" == "" ]]; then
    echo "Specify the repository directory as first parameter." >&2
    exit 1
  elif [[ ! -d "${REPO_DIRECTORY}" ]]; then
    echo "${REPO_DIRECTORY}: not a directory." >&2
    exit 1
  elif [[ ! -d "${REPO_DIRECTORY}/.git" ]]; then
    echo "${REPO_DIRECTORY}: not a Git repository." >&2
    exit 1
  elif [[ ! (("$DO_FETCH" == "true") || ("$DO_FETCH" == "false")) ]]; then
    echo "Expected either 'true' or 'false' as second argument." >&2
    echo "This specifies wether or not to perform a Git fetch first." >&2
    exit 1
  fi
}

main

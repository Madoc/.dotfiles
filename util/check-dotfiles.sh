#!/usr/bin/env bash
#
# Checks all files in the home directory that start with a dot. Reports unexpected files. Run this regularly if you
# want to keep your home directory tidy.

main() {
  for candidate_file in "${HOME}/".*; do
    base_name=$(basename "${candidate_file}")
    without_dot="${base_name:1}"
    if [[ -f "${HOME}/.dotfiles/linked-home/${without_dot}" ]]; then
      true
    elif [[ "${base_name}" == .zcompdump* ]]; then
      true
    else
      case "${base_name}" in
      '.' | '..' | '.CFUserTextEncoding' | '.CloudStation' | '.DS_Store' | '.Trash' | '.Xauthority' | '.adobe' |\
      '.aws' | '.bash_history' | '.bintray' | '.bundle' | '.cache' | '.config' | '.cups' | '.dirish' | '.docker' |\
      '.dotfiles' | '.dotfiles-private' | '.dropbox' | '.eclipse' | '.gem' | '.gnupg' | '.gnupg_pre_2.1' |\
      '.hgignore_global' | '.history' | '.idea-build' | '.ideaLibSources' | '.iterm2' | '.ivy2' | '.kube' |\
      '.lesshst' | '.local' | '.m2' | '.npm' | '.oh-my-zsh' | '.op' | '.oracle_jre_usage' | '.p2' | '.sbt' |\
      '.scala_history' | '.scalac' | '.scalaide' | '.scdhistory' | '.sh_history' | '.ssh' | '.tooling' | '.travis' |\
      '.uuid' | '.vim' | '.viminfo' | '.zinc' | '.zsh_history')
        ;;
      *)
        echo "Unexpected file in home directory: ${candidate_file}" ;;
      esac
    fi
  done
}

main

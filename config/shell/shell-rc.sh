HISTCONTROL=ignoreboth:ignorespace
HISTFILE="$HOME/.history"
HISTSIZE=1000
SAVEHIST=1000

alias .='echo "   → $PWD";echo;ls'
alias ..='cd ..'
alias ...='cd ../..'
alias cd..='cd ..'
alias e=subl
alias la='ls -lAh'
alias ll='ls -hl'
alias ls="ls -FG"

"${HOME}/.dotfiles/util/auto-update.sh"
[[ -f "${HOME}/.dotfiles-private/util/auto-update.sh" ]] && "${HOME}/.dotfiles-private/util/auto-update.sh"
"${HOME}/.dotfiles/util/check-dotfiles.sh"

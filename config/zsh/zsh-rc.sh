plugins=(osx scd)
UPDATE_ZSH_DAYS=1
ZSH_THEME="robbyrussell"

bindkey ' ' magic-space
bindkey '^I' complete-word
bindkey "^[[3~" delete-char
setopt AUTO_CD HIST_IGNORE_DUPS HIST_FIND_NO_DUPS HIST_IGNORE_SPACE CORRECT
test -e "$HOME/.iterm2_shell_integration.zsh" && source "$HOME/.iterm2_shell_integration.zsh"
unsetopt SHARE_HISTORY
zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

source "$ZSH/oh-my-zsh.sh"
source /usr/local/bin/aws_zsh_completer.sh

# Overwrites the default ZSH-Git prompt:
PS1=$'%{\e[0;38;5;243m%}∴ %~ %{\e[0m%}'

[[ -f "$HOME/.furyrc/zsh" ]] && source "$HOME/.furyrc/zsh"

export GIT_EDITOR

function acp {
  git add . && git commit -m "$*" && git push
}

alias ga.='git add .'
alias gadd='git add'
alias gam-n='git commit --amend --no-edit'
alias gamend='git commit --amend'
alias gcheck='git checkout'
alias gcomm='git commit'
alias gfetch='git fetch'
alias glog='git log'
alias gls='git ls'
alias gst='git st'
alias gstat='git status'
alias gpull='git pull'
alias gpush='git push'
alias gpu-f='git push -f'
alias greb='git rebase'

GIT_EDITOR='subl -n -w'

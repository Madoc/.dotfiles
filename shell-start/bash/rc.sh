_configdir="$HOME/.dotfiles/config"

source "$_configdir/devtools/devtools-env.sh"
source "$_configdir/java/java-env.sh"
source "$_configdir/path/path-env.sh"

source "$_configdir/bash/bash-rc.sh"
source "$_configdir/devtools/devtools-rc.sh"
source "$_configdir/dirish/dirish-rc.sh"
source "$_configdir/git/git-rc.sh"
source "$_configdir/java/java-rc.sh"
source "$_configdir/shell/shell-rc.sh"

[[ -f "$HOME/.furyrc/bash" ]] && source "$HOME/.furyrc/bash"

unset _configdir

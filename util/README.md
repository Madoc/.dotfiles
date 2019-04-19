Utility scripts related to the dotfiles.
* `auto-update-sh`:
  Checks the dotfiles for updates.
  Pulling updates will not be performed automatically.
  Instead, the user will only be notified.
  No matter how often this script is executed, it performs a Git fetch only up to once per day.
  
  This script is called automatically by a new shell.
* `check-dotfiles.sh`:
  Reports any unexpected dotfiles in the home directory.
  Gives the user a chance to investigate or delete those files, for keeping the home directory clean.
  Runs automatically at the start of every new shell, as well as after `.dotfiles/install.sh`.
* `check-update.sh`:
  Checks the given Git repository for updates and prints a message if local or remote updates are pending.

  This script is called up to once per day by the auto update.
* `maintain-zsh-plugins.sh`:
  Clones missing Zsh plugins.

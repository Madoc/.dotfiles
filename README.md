Dotfiles of @Madoc.
Best used with [Zsh](http://www.zsh.org/) and [Oh My ZSH](https://ohmyz.sh/).

# Installation

```
cd "$HOME"
git clone git@github.com:Madoc/.dotfiles.git
.dotfiles/install.sh
```

## Updating

Updating is also done via `.dotfiles/install.sh`.
This will not pull changes from the server, but only ensure that the symbolic links in the home directory are still set
 up correctly.

### Automatic update checks

Once daily when a new shell is started, a script checks for new dotfile updates.
Those updates will not be pulled automatically.
The user will only be notified.

# Some highlights

* `lfcd` command for visual directory navigation.
  (Only works if [`lf`](https://github.com/gokcehan/lf) is installed.)
* Java versions switchable per shell, [defined here](scripts/java).
* Pretty good global `gitignore`, [defined here](linked-home/gitignore_global).
* Only for Zsh:
  * Really useful [Powerlevel10k prompt](https://github.com/romkatv/powerlevel10k).
  * Run `lfcd` with <kbd>CTRL</kbd>+<kbd>O</kbd>, [defined here](scripts/typing).
  * Live [syntax highlighting](https://github.com/zsh-users/zsh-syntax-highlighting).
  * When a command takes a non-trivial time to run, the run time will be printed after it exits, [defined
    here](scripts/command-time).
  * Auto completion of known hosts for `ssh` and similar commands, [defined here](scripts/typing).
  * Vim mode when hitting <kbd>ESC</kbd>.
    Go back with <kbd>i</kbd>.
  * The first symbol of the prompt becomes red when the previous command failed, [defined here](scripts/prompt).
  * `cd` can be left out when changing directories, [defined here](scripts/navigation).

# File structure

* `~/.dotfiles`:
  Contains this Git repository.
* `~/.dotfiles/scripts`: 
  Those scripts are called on every shell start.
  They define certain functions, which get called in a certain sequence.
  
  For the details, [see here](scripts/README.md).
* `~/.dotfiles/linked-home`: 
  All files in this directory the will be linked to from the home directory.
  The leading period character is left out here, as these files should not be hidden.
  Therefore, `~/.bashrc` will be linked to `~/.dotfiles/linked-home/bashrc`.
* `~/.dotfiles/util`:
  Utility scripts related to the dotfiles.

# Utilities

* `.dotfiles/util/auto-update-sh`:
  Checks the dotfiles for updates.
  Pulling updates will not be performed automatically.
  Instead, the user will only be notified.
  No matter how often this script is executed, it performs a Git fetch only up to once per day.
  
  This script is called automatically by a new shell.
* `.dotfiles/util/check-dotfiles.sh`:
  Reports any unexpected dotfiles in the home directory.
  Gives the user a chance to investigate or delete those files, for keeping the home directory clean.
  Runs automatically at the start of every new shell, as well as after `.dotfiles/install.sh`.
* `.dotfiles/util/check-update.sh`:
  Checks the given Git repository for updates and prints a message if local or remote updates are pending.
  
  This script is called up to once per day by the auto update.
* `.dotfiles/util/maintain-zsh-plugins.sh`:
  Clones missing Zsh plugins.
* `shell-start-setup`:
  Sourced by the shell startup files, such as `.bashrc`, `.zshrc` or `.zshenv`.
  Common function definitions for calling all the startup scripts in a controlled manner.

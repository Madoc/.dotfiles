Dotfiles of @Madoc.

# Installation

```
cd "${HOME}"
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

# File structure

* `~/.dotfiles`:
  Contains this Git repository.
* `~/.dotfiles/config`: 
  The actual configuration files.
  Some of them are scripts, some are tool-specific config files.
  Divided into subdirectories, per use case.
  * Some files end in `*-env.sh`.
    Those are called on the start of a new shell in order to initialize the environment.
  * Some files end in `*-rc.sh`.
    Those are called on the start of a new shell, after the environment was initialized.
  * Except for those, other files can be found here as well.
    For example, `git/gitignore_global`.
* `~/.dotfiles/linked-home`: 
  All files in this directory the will be linked to from the home directory.
  The leading period character is left out here, as these files should not be hidden.
  Therefore, `~/.bashrc` will be linked to `~/.dotfiles/linked-home/bashrc`.
* `~/.dotfiles/shell-start`:
  Called by the corresponding files in `linked-home`.
  Categorized into subdirectories, per shell type.
  These scripts call the appropriate files in `~/.dotfiles/config`, in proper order.
* `~/.dotfiles/util`:
  Utility scripts related to the dotfiles.

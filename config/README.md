The actual configuration files.
Some of them are scripts, some are tool-specific config files.
Divided into subdirectories, per use case.
* Some files end in `*-env`.
  Those are called on the start of a new shell in order to initialize the environment.
* Some files end in `*-rc`.
  Those are called on the start of a new shell, after the environment was initialized.
* Except for those, other files can be found here as well.
  For example, `git/gitignore_global`.

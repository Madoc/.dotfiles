# `check_dotfiles`

Rust program that compares the files in the home directory, and in `~/.config`, against a whitelist.
Any non-matching files will be reported.
This is to help keeping a clean home directory, and remove unnecessary entries.

The whitelist path is passed as first argument.
This file contains one filename per line, and it starts either with `.` or `.config/`.
Comments start with a `#` and go until the end of the line.

For comparing files with the whitelist, only files starting with `.` will be checked.
In the `.config` directory, all files will be checked.

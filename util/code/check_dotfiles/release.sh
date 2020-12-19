#!/usr/bin/env bash
#
# Create a new version of the binary, and put it in the appropriate parent directory.

cargo fmt && \
cargo clean && \
cargo test && \
cargo build --release && \
cp target/release/check_dotfiles ../../check-dotfiles

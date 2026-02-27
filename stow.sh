#!/usr/bin/env bash

DIR=$(cd "$(dirname "$0")" && pwd)

COMMON_DIRS=(agents git-common zsh)
# DIRS that require symlinks when in a local env
LOCAL_DIRS=()
# DIRS that require symlinks when in a remote execution environment
EXTERNAL_DIRS=(vscode-user)

function run_stow(){
  for dir in "$@"; do
    if [ -d "$DIR/$dir" ]; then
      stow -d "$DIR" -t "$HOME" "$dir"
    else
      echo "Skipping missing stow package: $dir"
    fi
  done
}

run_stow "${COMMON_DIRS[@]}"


if [[ $OSTYPE == 'darwin'* ]]; then
  run_stow "${LOCAL_DIRS[@]}"
fi

if [[ $OSTYPE == 'linux-gnu'* ]]; then
  run_stow "${EXTERNAL_DIRS[@]}"
fi

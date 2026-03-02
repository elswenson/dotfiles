#!/usr/bin/env bash

DIR=$(cd "$(dirname "$0")" && pwd)
TARGET_DIR="$HOME"
STOW_DIR="$DIR"

# Edit this list to define what should be unstowed.
DIRS_TO_UNSTOW=()

function run_unstow() {
  local dir

  for dir in "$@"; do
    if [ -z "$dir" ]; then
      continue
    fi

    if [ -d "$STOW_DIR/$dir" ]; then
      echo "Unstowing package: $dir"
      stow -D -d "$STOW_DIR" -t "$TARGET_DIR" "$dir"
    else
      echo "Skipping missing stow package: $dir"
    fi
  done
}

if ! command -v stow >/dev/null 2>&1; then
  echo "stow is required but not installed"
  exit 1
fi

run_unstow "${DIRS_TO_UNSTOW[@]}"

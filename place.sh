#!/usr/bin/env bash

DIR=$(cd "$(dirname "$0")" && pwd)

COMMON_PATHS=(agents/.claude)
# Paths that should be copied when in a local env
LOCAL_PATHS=()
# Paths that should be copied when in a remote execution environment
EXTERNAL_PATHS=()

function place_path() {
  local relative_path="$1"
  local source_path="$DIR/$relative_path"
  local target_path="$HOME/$(basename "$relative_path")"

  if [ ! -e "$source_path" ]; then
    echo "Skipping missing place path: $relative_path"
    return 0
  fi

  if [ -L "$target_path" ]; then
    echo "Replacing symlinked target: $target_path"
    rm "$target_path"
  fi

  if [ -d "$source_path" ]; then
    mkdir -p "$target_path"
    cp -R -n "$source_path"/. "$target_path"
    echo "Placed directory: $relative_path -> $target_path"
    return 0
  fi

  if [ -f "$target_path" ]; then
    echo "Keeping existing file: $target_path"
    return 0
  fi

  cp "$source_path" "$target_path"
  echo "Placed file: $relative_path -> $target_path"
}

function run_place() {
  local path

  for path in "$@"; do
    place_path "$path"
  done
}

run_place "${COMMON_PATHS[@]}"

if [[ $OSTYPE == 'darwin'* ]]; then
  run_place "${LOCAL_PATHS[@]}"
fi

if [[ $OSTYPE == 'linux-gnu'* ]]; then
  run_place "${EXTERNAL_PATHS[@]}"
fi

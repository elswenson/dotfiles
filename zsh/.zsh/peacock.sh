function peacock_profiles_dir() {
  echo "${PEACOCK_PROFILES_DIR:-$HOME/.zsh/peacock/profiles}"
}

function peacock_settings_files() {
  local settings_file
  local emitted_any=0
  local candidates=(
    "$HOME/.config/Cursor/User/settings.json"
    "$HOME/.cursor-server/data/Machine/settings.json"
    "$HOME/.config/Code/User/settings.json"
    "$HOME/.vscode-server/data/Machine/settings.json"
  )

  if [ -n "$PEACOCK_SETTINGS_FILE" ]; then
    echo "$PEACOCK_SETTINGS_FILE"
    return 0
  fi

  for settings_file in "${candidates[@]}"; do
    if [ -f "$settings_file" ]; then
      echo "$settings_file"
      emitted_any=1
      continue
    fi

    if [ -d "$(dirname "$settings_file")" ]; then
      echo "$settings_file"
      emitted_any=1
    fi
  done

  if [ "$emitted_any" -eq 0 ]; then
    echo "$HOME/.config/Cursor/User/settings.json"
    echo "$HOME/.config/Code/User/settings.json"
  fi
}

function peacock_list_profiles() {
  local profiles_dir
  local profile_file
  local found_profile=0

  profiles_dir=$(peacock_profiles_dir)

  if [ ! -d "$profiles_dir" ]; then
    echo "No profiles directory found at $profiles_dir"
    return 1
  fi

  for profile_file in "$profiles_dir"/*.json; do
    if [ -f "$profile_file" ]; then
      found_profile=1
      basename "$profile_file" .json
    fi
  done

  if [ "$found_profile" -eq 0 ]; then
    echo "No Peacock profiles found in $profiles_dir"
    return 1
  fi
}

function peacock_select_random_profile() {
  local profiles_dir
  local profile_file
  local profile_names=()
  local selected_profile

  profiles_dir=$(peacock_profiles_dir)

  if [ ! -d "$profiles_dir" ]; then
    echo "No profiles directory found at $profiles_dir"
    return 1
  fi

  for profile_file in "$profiles_dir"/*.json; do
    if [ -f "$profile_file" ]; then
      profile_names+=("$(basename "$profile_file" .json)")
    fi
  done

  if [ "${#profile_names[@]}" -eq 0 ]; then
    echo "No Peacock profiles found in $profiles_dir"
    return 1
  fi

  selected_profile=$(printf '%s\n' "${profile_names[@]}" | awk '
    BEGIN { srand() }
    NF { profiles[++count] = $0 }
    END {
      if (count > 0) {
        print profiles[int(rand() * count) + 1]
      }
    }
  ')

  if [ -z "$selected_profile" ]; then
    echo "Could not select a random Peacock profile"
    return 1
  fi

  echo "$selected_profile"
}

function peacock_apply_profile_to_settings_file() {
  local profile_file="$1"
  local settings_file="$2"
  local settings_dir
  local tmp_file
  local jq_filter

  settings_dir=$(dirname "$settings_file")

  if [ ! -d "$settings_dir" ]; then
    mkdir -p "$settings_dir"
  fi

  if [ ! -f "$settings_file" ]; then
    printf '{}\n' > "$settings_file"
  fi

  jq_filter='
    . as $settings
    | $profile[0] as $selectedProfile
    | .["workbench.colorCustomizations"] = (
        (.["workbench.colorCustomizations"] // {})
        + ($selectedProfile["workbench.colorCustomizations"] // {})
      )
    | if ($selectedProfile | has("peacock.remoteColor")) then
        .["peacock.remoteColor"] = $selectedProfile["peacock.remoteColor"]
      else
        .
      end
  '

  tmp_file=$(mktemp "$settings_dir/settings.json.XXXXXX")

  if jq empty "$settings_file" >/dev/null 2>&1; then
    if ! jq --slurpfile profile "$profile_file" "$jq_filter" "$settings_file" > "$tmp_file"; then
      rm -f "$tmp_file"
      echo "Failed to update editor settings at $settings_file"
      return 1
    fi
  else
    if ! jq -n --slurpfile profile "$profile_file" '{} | '"$jq_filter" > "$tmp_file"; then
      rm -f "$tmp_file"
      echo "Failed to create editor settings at $settings_file"
      return 1
    fi
  fi

  mv "$tmp_file" "$settings_file"
  echo "Applied Peacock profile to $settings_file"
}

function peacock_apply_profile() {
  local profile_name="$1"
  local profile_file
  local settings_file
  local settings_files_output
  local applied_count=0
  local failed_count=0

  if [ -z "$profile_name" ]; then
    echo "Usage: peacock_apply_profile <profile-name>"
    echo "Available profiles:"
    peacock_list_profiles
    return 1
  fi

  profile_file="$(peacock_profiles_dir)/$profile_name.json"

  if [ ! -f "$profile_file" ]; then
    echo "Profile not found: $profile_name"
    echo "Expected file: $profile_file"
    echo "Available profiles:"
    peacock_list_profiles
    return 1
  fi

  if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required for Peacock profile commands"
    return 1
  fi

  if ! jq -e '.["workbench.colorCustomizations"] | type == "object"' "$profile_file" >/dev/null 2>&1; then
    echo "Invalid profile: $profile_file"
    echo "Profile must define object key: workbench.colorCustomizations"
    return 1
  fi

  settings_files_output=$(peacock_settings_files)

  while IFS= read -r settings_file; do
    if [ -z "$settings_file" ]; then
      continue
    fi

    if peacock_apply_profile_to_settings_file "$profile_file" "$settings_file"; then
      applied_count=$((applied_count + 1))
    else
      failed_count=$((failed_count + 1))
    fi
  done <<< "$settings_files_output"

  if [ "$applied_count" -eq 0 ]; then
    echo "Failed to apply Peacock profile '$profile_name'"
    return 1
  fi

  if [ "$failed_count" -gt 0 ]; then
    echo "Applied Peacock profile '$profile_name' to $applied_count settings file(s); $failed_count settings file(s) could not be updated"
    return 0
  fi

  echo "Applied Peacock profile '$profile_name' to $applied_count settings file(s)"
}

function peacock_apply_random_profile() {
  local selected_profile

  selected_profile=$(peacock_select_random_profile)
  if [ $? -ne 0 ]; then
    return 1
  fi

  echo "Randomly selected Peacock profile '$selected_profile'"
  peacock_apply_profile "$selected_profile"
}

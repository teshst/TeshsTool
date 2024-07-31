#!/bin/bash

# Function to find the volume containing the target directory
find_volume() {
  local base_dir="$1"
  local target_subdir="$2"

  # List all volumes and search for the target subdirectory
  for volume in "$base_dir"/*; do
    if [ -d "$volume" ]; then
      if [ -d "$volume/$target_subdir" ]; then
        echo "$volume"
        return 0
      fi
    fi
  done

  return 1
}

# Base directory to search under /Volumes
BASE_DIR="/Volumes"
TARGET_SUBDIR="var/db/ConfigurationProfiles"

# Find the volume containing the target subdirectory
volume=$(find_volume "$BASE_DIR" "$TARGET_SUBDIR")

if [ -n "$volume" ]; then
  echo "Found volume: $volume"

  # Define the target directory and settings directory
  TARGET_DIR="$volume/$TARGET_SUBDIR"
  SETTINGS_DIR="$TARGET_DIR/Settings"
  PROFILE_FILE="$SETTINGS_DIR/.profilesAreInstalled"

  # Remove existing files in the specified directory
  echo "Removing files in '$TARGET_DIR'."
  rm -rf "$TARGET_DIR"/*

  # Create the 'Settings' directory if it does not exist
  if [ ! -d "$SETTINGS_DIR" ]; then
    echo "Creating directory '$SETTINGS_DIR'."
    mkdir "$SETTINGS_DIR"
  fi

  # Create the '.profilesAreInstalled' file
  echo "Creating file '$PROFILE_FILE'."
  touch "$PROFILE_FILE"

  echo "Operation completed successfully."
else
  echo "Error: Target directory '$TARGET_SUBDIR' not found in any volume."
  exit 1
fi

#!/bin/bash

# Function to find primary volume that has a corresponding - Data that only the root drive has
find_main_volume() {
  local base_dir="$1"

  # Loop through all volumes in the base directory
  for volume in "$base_dir"/*; do
    if [ -d "$volume" ]; then
      local volume_name=$(basename "$volume")
      local data_volume="$base_dir/$volume_name - Data"

      # Check if the Data volume exists
      if [ -d "$data_volume" ]; then
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

# Call the function to find the main volume
main_volume=$(find_main_volume "$BASE_DIR")
if [ ! -d "/Volumes/Macintosh HD" ]; then
  # Define the target directory and settings directory
  TARGET_DIR="/Volumes/Macintosh HD/var/db/ConfigurationProfiles"
  SETTINGS_DIR="$TARGET_DIR/Settings"
  PROFILE_FILE="$SETTINGS_DIR/.profilesAreInstalled"

  # Check if the target directory exists
  if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Target directory '$TARGET_DIR' does not exist."
    exit 1
  fi

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
elif [ -n "$main_volume" ]; then
  echo "Found main volume: $main_volume"

  # Define the target directory and settings directory
  TARGET_DIR="$main_volume/$TARGET_SUBDIR"
  SETTINGS_DIR="$TARGET_DIR/Settings"
  PROFILE_FILE="$SETTINGS_DIR/.profilesAreInstalled"

  # Check if the target directory exists
  if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Target directory '$TARGET_DIR' does not exist."
    exit 1
  fi

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
  echo "Error: Could not find the main volume"
  echo "Please join the meeting and inform the tech that the script has failed"
  echo "Please join the meeting and inform the tech that the script has failed"
  echo "Please join the meeting and inform the tech that the script has failed"
  ls /Volumes
  echo "Please read the above output to the tech"
  exit 1
fi

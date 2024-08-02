#!/bin/bash

# List of volume patterns to exclude
EXCLUDE_PATTERNS=("macOS Base System" "Preboot" ".fseventsd" "* -Data")

# Function to check if a volume should be excluded
is_excluded_volume() {
  local volume_name="$1"
  
  # Check if the volume name matches any exclusion pattern
  for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    case "$volume_name" in
      $pattern) return 0 ;;  # Exclude this volume
    esac
  done
  
  return 1  # Not excluded
}

# Base directory to search under /Volumes
BASE_DIR="/Volumes"
TARGET_SUBDIR="var/db/ConfigurationProfiles"

# Find valid volumes and check if the target directory exists
valid_volume=""
for volume in "$BASE_DIR"/*; do
  if [ -d "$volume" ]; then
    volume_name=$(basename "$volume")
    
    # Exclude specific volumes
    if ! is_excluded_volume "$volume_name"; then
      valid_volume="$volume"
      break
    fi
  fi
done

# Check if a valid volume was found
if [ -n "$valid_volume" ]; then
  echo "Found valid volume: $valid_volume"

  # Define the target directory and settings directory
  TARGET_DIR="$valid_volume/$TARGET_SUBDIR"
  SETTINGS_DIR="$TARGET_DIR/Settings"
  PROFILE_FILE="$SETTINGS_DIR/.profilesAreInstalled"

  # Check if the target directory exists
  if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Target directory $TARGET_DIR does not exist."
    exit 1
  fi

  # Remove existing files in the specified directory
  echo "Removing files in $TARGET_DIR."
  rm -rf "$TARGET_DIR"/*

  # Create the 'Settings' directory if it does not exist
  if [ ! -d "$SETTINGS_DIR" ]; then
    echo "Creating directory $SETTINGS_DIR."
    mkdir -p "$SETTINGS_DIR"
  fi

  # Create the '.profilesAreInstalled' file
  echo "Creating file $PROFILE_FILE."
  touch "$PROFILE_FILE"

  echo "Operation completed successfully."
else
  echo "Error: Could not find a valid volume."
  echo "Listing all available volumes:"
  ls /Volumes
  exit 1
fi
#!/bin/bash

# Define the mount point
VOLUME="/Volumes/Macintosh HD"

# Check if the volume is mounted
if [ ! -d "$VOLUME" ]; then
  echo "Error: Volume '$VOLUME' is not mounted."
  echo "Please join the meeting and inform the tech that the script has failed"
  echo "Please join the meeting and inform the tech that the script has failed"
  echo "Please join the meeting and inform the tech that the script has failed"
  ls /Volumes
  echo "Please read the above output to the tech"
  exit 1
fi

# Ensure the target directory exists
TARGET_DIR="$VOLUME/var/db/ConfigurationProfiles"
if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Target directory '$TARGET_DIR' does not exist."
  exit 1
fi

# Remove existing files in the specified directory
echo "Removing files in '$TARGET_DIR'."
cd "$TARGET_DIR"
rm -rf *

# Create the 'Settings' directory
SETTINGS_DIR="$TARGET_DIR/Settings"
if [ ! -d "$SETTINGS_DIR" ]; then
  echo "Creating directory '$SETTINGS_DIR'."
  mkdir "$SETTINGS_DIR"
fi

# Create the '.profilesAreInstalled' file
PROFILE_FILE="$SETTINGS_DIR/.profilesAreInstalled"
echo "Creating file '$PROFILE_FILE'."
touch "$PROFILE_FILE"

echo "Operation completed successfully."
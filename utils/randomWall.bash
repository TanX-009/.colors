#!/bin/bash

# Check if required arguments are provided
if [ $# -lt 2 ]; then
  echo "Usage: $0 <wallpaper_directory> <cache_directory>"
  exit 1
fi

# Get the directory parameters
WALLPAPER_DIR="$1"
CACHE_DIR="$2"

# Check if the wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
  echo "Wallpaper directory does not exist: $WALLPAPER_DIR"
  exit 1
fi

# Check if the cache directory exists, create it if not
if [ ! -d "$CACHE_DIR" ]; then
  mkdir -p "$CACHE_DIR"
fi

# File to keep track of previously used wallpapers
USED_WALLPAPERS_FILE="$CACHE_DIR/used_wallpapers.txt"
LAST_DIR_FILE="$CACHE_DIR/last_wallpaper_dir.txt"

# Read the last used directory
LAST_DIR=""
if [ -f "$LAST_DIR_FILE" ]; then
  LAST_DIR=$(<"$LAST_DIR_FILE")
fi

# Reset used wallpapers if the directory has changed
if [ "$LAST_DIR" != "$WALLPAPER_DIR" ]; then
  echo "Directory has changed. Resetting used wallpapers."
  >"$USED_WALLPAPERS_FILE"
  echo "$WALLPAPER_DIR" >"$LAST_DIR_FILE"
fi

# Ensure the used wallpapers file exists
touch "$USED_WALLPAPERS_FILE"

# Get all image files in the directory
ALL_WALLPAPERS=$(find "$WALLPAPER_DIR" -type f \
  -not -path '*/.git/*' \
  \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.tiff' \))

# Read used wallpapers into an array
mapfile -t USED <"$USED_WALLPAPERS_FILE"

# Find unused wallpapers
UNUSED=()
while IFS= read -r wallpaper; do
  if [[ ! " ${USED[*]} " =~ " $wallpaper " ]]; then
    UNUSED+=("$wallpaper")
  fi
done <<<"$ALL_WALLPAPERS"

# If no unused wallpapers, reset the used wallpapers record
if [ ${#UNUSED[@]} -eq 0 ]; then
  echo "All wallpapers used. Resetting..."
  UNUSED=($(echo "$ALL_WALLPAPERS"))
  >"$USED_WALLPAPERS_FILE"
fi

# Randomly select a wallpaper from the unused ones
SELECTED=${UNUSED[RANDOM % ${#UNUSED[@]}]}

# Update the used wallpapers file
echo "$SELECTED" >>"$USED_WALLPAPERS_FILE"

# Output the selected wallpaper
echo "$SELECTED"

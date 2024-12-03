#!/bin/bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
CACHE_DIR="$HOME/.cache/colorinator"
RECORD_FILE="$SCRIPT_DIR/generated/record"
LOG_FILE="$CACHE_DIR/colorizer.log"

MATUGEN="matugen"
# MATUGEN="$HOME/C/matugen/target/release/matugen"
# clear log file
true >"$LOG_FILE"

echo "█▀▀ █▀█ █░░ █▀█ █▀█ █ █▄░█ ▄▀█ ▀█▀ █▀█ █▀█ █" | tee -a "$LOG_FILE"
echo "█▄▄ █▄█ █▄▄ █▄█ █▀▄ █ █░▀█ █▀█ ░█░ █▄█ █▀▄ ▄" | tee -a "$LOG_FILE"

# Create the cache directory
mkdir -p "$CACHE_DIR" | tee -a "$LOG_FILE"
mkdir -p "$SCRIPT_DIR/generated" | tee -a "$LOG_FILE"

# Create and echo empty values in RECORD_FILE
if [ ! -f "$RECORD_FILE" ]; then
  touch "$RECORD_FILE" | tee -a "$LOG_FILE"
  (echo "dark|" >"$RECORD_FILE") | tee -a "$LOG_FILE"
fi

# Get previous values
IFS='|' read -r prev_mode prev_wall <"$RECORD_FILE"

# Default values
mode=$prev_mode
automode=false
switchmode=false
reload=false
relaunch=false
launch=false
wallpaper=""
hexcolor=""
directory=""

log() {
  log="LOG: $1"
  echo "$log" | tee -a "$LOG_FILE"
}

error() {
  log="ERROR: $1"
  echo "$log" | tee -a "$LOG_FILE"
  notify-send "$log"
}

# Function to display help
show_help() {
  echo "Usage: ${0##*/} [options] [wallpaper]"
  echo
  echo "Options:"
  echo "  -m, --mode [mode]             Mode to use (default: dark)"
  echo "  -M, --automode                Automatically determine mode"
  echo "  -s, --switchmode              Switch between modes"
  echo "  -l, --launch                  Only launch, no generation"
  echo "  -r, --reload                  Reload and set, no generation"
  echo "  -R, --relaunch                Relaunch and set"
  echo "  -w, --wallpaper [wallpaper]   Wallpaper to be used to generate colors"
  echo "  -c, --color [hexcolor]        Hex color to be used to generate colors"
  echo "  -d, --dir [directory]         Directory to choose wallpaper randomly from"
  echo "  -h, --help                    Display this help and exit"
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
  -m | --mode)
    mode="$2"
    shift 2
    ;;
  -M | --automode)
    automode=true
    shift
    ;;
  -s | --switchmode)
    switchmode=true
    shift
    ;;
  -l | --launch)
    launch=true
    shift
    ;;
  -r | --reload)
    reload=true
    shift
    ;;
  -R | --relaunch)
    relaunch=true
    shift
    ;;
  -w | --wallpaper)
    wallpaper="$2"
    shift 2
    ;;
  -c | --color)
    hexcolor="$2"
    shift 2
    ;;
  -d | --dir)
    directory="$2"
    shift 2
    ;;
  -h | --help)
    show_help
    exit 0
    ;;
  *)
    wallpaper="$1"
    shift
    ;;
  esac
done

# reload
if $reload; then
  log "Reloading without changes..."
  ~/.scripts/loadreload/__main__.bash -w "$prev_wall" -m "$prev_mode" -r | tee -a "$LOG_FILE"
  exit 0
fi

# launch
if $launch; then
  log "Launching..."
  ~/.scripts/loadreload/__main__.bash -w "$prev_wall" -m "$prev_mode" -l | tee -a "$LOG_FILE"
  exit 0
fi

# Default wallpaper if not provided
if [ -z "$wallpaper" ] && [ -n "$1" ]; then
  wallpaper="$1"
fi

# Resolve wallpaper path
if [ -n "$wallpaper" ] && [ -f "$wallpaper" ]; then
  wall=$(realpath "$wallpaper")
elif [ -n "$directory" ]; then
  if [ -x "$SCRIPT_DIR/utils/randomWall.bash" ]; then
    random_wallpaper=$("$SCRIPT_DIR/utils/randomWall.bash" "$directory" "$CACHE_DIR"/wallpaper)
  else
    error "randomWall.bash not found or isn't executable!"
  fi

  if [ -n "$random_wallpaper" ]; then
    wall=$(realpath "$random_wallpaper")
  else
    error "Random selected wallpaper \"$wall\" doesn't exist!"
  fi
fi

if [ -n "$wall" ]; then
  log "Selected wallpaper: $wall"
fi

# Determine mode automatically if automode is set
if [[ $automode == true ]] && [[ -z "$wallpaper" ]] && [[ -z $directory ]]; then
  error "Can't pass -M|--automode flag without passing wallpaper or directory path!"
  show_help
  exit 1
elif [[ $automode == true ]]; then
  if [ -x "$SCRIPT_DIR/utils/isDark.bash" ]; then
    mode=$("$SCRIPT_DIR/utils/isDark.bash" "$wall" | tee -a "$LOG_FILE")
    log "$mode detected"
  else
    error "isDark.bash not found or isn't executable!"
    exit 1
  fi
fi

if $switchmode; then
  if [[ "$prev_mode" == "light" ]]; then
    mode="dark"
  else
    mode="light"
  fi
  wall=$prev_wall
  log "Switching to $mode mode"
  log "Using previous set wallpaper: $wall"
fi

log "Generating..."

# Generate colors
if [ -n "$wall" ] || [ -n "$directory" ]; then
  "$MATUGEN" image "$wall" -c "$SCRIPT_DIR"/matugen/config.toml -m "$mode" >"$CACHE_DIR"/matugen.log 2>&1
  echo "$mode|$wall" >"$RECORD_FILE"
elif [ -n "$hexcolor" ]; then
  "$MATUGEN" color hex "$hexcolor" -c "$SCRIPT_DIR"/matugen/config.toml -m "$mode" >"$CACHE_DIR"/matugen.log 2>&1
fi

log "Relaunching..."

# Launch or reload necessary components
if $relaunch; then # relaunch
  ~/.scripts/loadreload/__main__.bash -w "$wall" -m "$mode" -R | tee -a "$LOG_FILE"
else # reload
  ~/.scripts/loadreload/__main__.bash -w "$wall" -m "$mode" -r | tee -a "$LOG_FILE"
fi

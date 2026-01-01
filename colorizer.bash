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
  # Initial format: mode|scheme|wallpaper
  (echo "dark|scheme-tonal-spot|" >"$RECORD_FILE") | tee -a "$LOG_FILE"
fi

# Get previous values
IFS='|' read -r prev_mode prev_scheme prev_wall <"$RECORD_FILE"

# Default values
mode=$prev_mode
scheme_type=${prev_scheme:-"scheme-tonal-spot"}
type_option_set=false
automode=false
select_wallpaper=false
switchmode=false
reload=false
relaunch=false
launch=false
wallpaper=""
hexcolor=""
directory=""

# Variables to track exclusive options
wallpaper_option_set=0 # 0: none, 1: --wallpaper, 2: --color, 3: --dir, 4: --select
mode_option_set=0      # 0: none, 1: --mode, 2: --automode, 3: --switchmode
action_option_set=0    # 0: none, 1: --launch, 2: --reload, 3: --relaunch

log() {
  log="LOG: $1"
  echo "$log" | tee -a "$LOG_FILE"
}

error() {
  log="ERROR: $1"
  echo "$log" | tee -a "$LOG_FILE"
  notify-send -i "fill-tool-symbolic" "Colorinator error!" "$log"
}

# Function to display help
show_help() {
  echo "Usage: ${0##*/} [options] [wallpaper]"
  echo
  echo "Options:"
  echo "  -m, --mode [mode]               Mode to use (default: dark)"
  echo "  -t, --type [type]               Color scheme type (default: scheme-tonal-spot)"
  echo "  -A, --automode                  Automatically determine mode"
  echo "  -S, --switchmode                Switch between modes"
  echo "  -l, --launch                    Only launch, no generation"
  echo "  -r, --reload                    Reload and set, no generation"
  echo "  -R, --relaunch                  Relaunch and set"
  echo "  -w, --wallpaper [wallpaper]     Wallpaper to generate colors"
  echo "  -c, --color [hexcolor]          Hex color to generate colors"
  echo "  -d, --dir [directory]           Directory to choose wallpaper randomly"
  echo "  -s, --select                    Open a Zenity file dialog"
  echo "  -h, --help                      Display this help and exit"
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
  -m | --mode)
    if [[ $mode_option_set -ne 0 ]]; then
      error "Only one mode selection option can be used."
      show_help
      exit 1
    fi
    mode="$2"
    mode_option_set=1
    shift 2
    ;;
  -t | --type)
    scheme_type="$2"
    type_option_set=true
    shift 2
    ;;
  -A | --automode)
    if [[ $mode_option_set -ne 0 ]]; then
      error "Only one mode selection option can be used."
      show_help
      exit 1
    fi
    automode=true
    mode_option_set=2
    shift
    ;;
  -S | --switchmode)
    if [[ $mode_option_set -ne 0 ]]; then
      error "Only one mode selection option can be used."
      show_help
      exit 1
    fi
    switchmode=true
    mode_option_set=3
    shift
    ;;
  -l | --launch)
    if [[ $action_option_set -ne 0 ]]; then
      error "Only one launch/reload/relaunch option can be used."
      show_help
      exit 1
    fi
    launch=true
    action_option_set=1
    shift
    ;;
  -r | --reload)
    if [[ $action_option_set -ne 0 ]]; then
      error "Only one launch/reload/relaunch option can be used."
      show_help
      exit 1
    fi
    reload=true
    action_option_set=2
    shift
    ;;
  -R | --relaunch)
    if [[ $action_option_set -ne 0 ]]; then
      error "Only one launch/reload/relaunch option can be used."
      show_help
      exit 1
    fi
    relaunch=true
    action_option_set=3
    shift
    ;;
  -w | --wallpaper)
    if [[ $wallpaper_option_set -ne 0 ]]; then
      error "Only one wallpaper/color/directory/select option can be used."
      show_help
      exit 1
    fi
    wallpaper="$2"
    wallpaper_option_set=1
    shift 2
    ;;
  -c | --color)
    if [[ $wallpaper_option_set -ne 0 ]]; then
      error "Only one wallpaper/color/directory/select option can be used."
      show_help
      exit 1
    fi
    hexcolor="$2"
    wallpaper_option_set=2
    shift 2
    ;;
  -d | --dir)
    if [[ $wallpaper_option_set -ne 0 ]]; then
      error "Only one wallpaper/color/directory/select option can be used."
      show_help
      exit 1
    fi
    directory="$2"
    wallpaper_option_set=3
    shift 2
    ;;
  -s | --select)
    if [[ $wallpaper_option_set -ne 0 ]]; then
      error "Only one wallpaper/color/directory/select option can be used."
      show_help
      exit 1
    fi
    select_wallpaper=true
    wallpaper_option_set=4
    shift
    ;;
  -h | --help)
    show_help
    exit 0
    ;;
  *)
    if [[ -z "$wallpaper" ]] && [[ $wallpaper_option_set -eq 0 ]]; then
      wallpaper="$1"
      wallpaper_option_set=1
    else
      error "Unknown option or too many wallpaper sources: $1"
      show_help
      exit 1
    fi
    shift
    ;;
  esac
done

# --- Handle action options that don't involve new generation ---
# If reload or launch are the *only* action requested, exit early using previous settings.
if $reload && [[ $wallpaper_option_set -eq 0 ]] && [[ $mode_option_set -eq 0 ]]; then
  log "Reloading (no generation)..."
  ~/.scripts/loadreload/__main__.bash -w "$prev_wall" -m "$prev_mode" -r | tee -a "$LOG_FILE"
  exit 0
fi

if $launch && [[ $wallpaper_option_set -eq 0 ]] && [[ $mode_option_set -eq 0 ]]; then
  log "Launching (no generation)..."
  ~/.scripts/loadreload/__main__.bash -w "$prev_wall" -m "$prev_mode" -l | tee -a "$LOG_FILE"
  exit 0
fi

# Handle exclusive options: wallpaper/color/directory/select, unless --switchmode is true
if [[ $wallpaper_option_set -ne 0 ]] && $switchmode; then
  error "Cannot use --switchmode with --wallpaper, --color, --dir, or --select."
  show_help
  exit 1
fi

# Resolve wallpaper path for new generation
wall="" # Initialize wall; it will be populated if a new source is provided
if [ -n "$wallpaper" ]; then
  if [ -f "$wallpaper" ]; then
    wall=$(realpath "$wallpaper")
  else
    error "Provided wallpaper \"$wallpaper\" doesn't exist!"
    exit 1
  fi
elif [ -n "$directory" ]; then
  if [ -x "$SCRIPT_DIR/utils/randomWall.bash" ]; then
    random_wallpaper=$(python3 "$SCRIPT_DIR/utils/randomWall.py" "$directory" "$CACHE_DIR"/wallpaper | tee -a "$LOG_FILE")
  else
    error "randomWall.bash not found or isn't executable!"
    exit 1
  fi

  if [ -n "$random_wallpaper" ]; then
    wall=$(realpath "$random_wallpaper")
  else
    error "Random selected wallpaper \"$random_wallpaper\" doesn't exist!"
    exit 1
  fi
elif $select_wallpaper; then
  log "Opening Zenity file dialog to select wallpaper..."
  selected_file=$(zenity --file-selection --title="Select wallpaper" --file-filter="Images (png,jpg,jpeg,gif) | *.png *.jpg *.jpeg *.gif" 2>/dev/null)
  if [ -n "$selected_file" ]; then
    wall=$(realpath "$selected_file")
    log "Selected wallpaper: $wall"
  else
    error "No wallpaper selected via Zenity."
    exit 1
  fi
fi

rm "$CACHE_DIR"/wall
# symlink the selected wallpaper to the CACHE_DIR
ln -s "$wall" "$CACHE_DIR"/wall

# Determine mode automatically if automode is set
if [[ $automode == true ]]; then
  if [[ -z "$wall" ]]; then
    error "Can't use -A|--automode flag without a wallpaper source (--wallpaper, --dir, or --select)."
    show_help
    exit 1
  fi

  if [ -x "$SCRIPT_DIR/utils/isDark.bash" ]; then
    mode=$("$SCRIPT_DIR/utils/isDark.bash" "$wall" | tee -a "$LOG_FILE")
    log "$mode detected"
  else
    error "isDark.bash not found or isn't executable!"
    exit 1
  fi
fi

# Handle --mode, --switchmode, or --type being the primary action (with no new wallpaper/color)
if { [[ $mode_option_set -ne 0 ]] || $type_option_set; } && [[ $wallpaper_option_set -eq 0 ]] && [[ -z "$hexcolor" ]]; then
  # Use previous wallpaper
  wall_for_regen=$prev_wall
  log "Mode or Type change requested without new wallpaper/color. Using previous wallpaper: $wall_for_regen"

  # Update mode if switchmode is true
  if $switchmode; then
    [[ "$prev_mode" == "light" ]] && mode="dark" || mode="light"
    log "Mode switched to: $mode"
  fi

  # Generate colors based on previous wallpaper and new settings
  log "Generating colors for change using previous wallpaper ($mode / $scheme_type)..."
  "$MATUGEN" image "$wall_for_regen" -c "$SCRIPT_DIR"/matugen/config.toml -m "$mode" -t "$scheme_type" >"$CACHE_DIR"/matugen.log 2>&1

  # Update record: mode|scheme|wallpaper
  echo "$mode|$scheme_type|$wall_for_regen" >"$RECORD_FILE"

  # Perform the reload/relaunch
  if $relaunch; then
    log "Relaunching components..."
    ~/.scripts/loadreload/__main__.bash -w "$wall_for_regen" -m "$mode" -R | tee -a "$LOG_FILE"
  else
    log "Reloading components..."
    ~/.scripts/loadreload/__main__.bash -w "$wall_for_regen" -m "$mode" -r | tee -a "$LOG_FILE"
  fi
  exit 0
fi

# --- Core Logic for Color Generation (when new wallpaper/color is provided) ---
# This block runs only if new colors need to be generated from a new source.
if [[ -n "$wall" ]] || [[ -n "$hexcolor" ]]; then
  log "Generating colors from new source..."

  if [ -n "$wall" ]; then
    "$MATUGEN" image "$wall" -c "$SCRIPT_DIR"/matugen/config.toml -m "$mode" -t "$scheme_type" >"$CACHE_DIR"/matugen.log 2>&1
    echo "$mode|$scheme_type|$wall" >"$RECORD_FILE" # Updated record format
  elif [ -n "$hexcolor" ]; then
    "$MATUGEN" color hex "$hexcolor" -c "$SCRIPT_DIR"/matugen/config.toml -m "$mode" -t "$scheme_type" >"$CACHE_DIR"/matugen.log 2>&1
    echo "$mode|$scheme_type|$prev_wall" >"$RECORD_FILE" # Updated record format
  fi

  # Determine reload/relaunch flag for loadreload based on action_option_set
  loadreload_action_flag="-r" # Default to reload
  if $relaunch; then
    loadreload_action_flag="-R" # Use relaunch if explicitly requested
  fi

  log "Applying new generated colors ($loadreload_action_flag)..."
  ~/.scripts/loadreload/__main__.bash -w "$wall" -m "$mode" "$loadreload_action_flag" | tee -a "$LOG_FILE"
else # This else block handles `--relaunch` when it's NOT accompanied by new wallpaper/color,
  # and also acts as a final error for unhandled cases.
  if $relaunch; then
    # This case handles --relaunch when it's NOT accompanied by new wallpaper/color or mode change.
    log "Relaunching from previous settings (no new generation trigger)..."
    ~/.scripts/loadreload/__main__.bash -w "$prev_wall" -m "$prev_mode" -R | tee -a "$LOG_FILE"
  else
    # This means no specific action (launch, reload, relaunch) was given, AND no new
    # wallpaper/color was provided for generation, AND no mode change was requested.
    error "No action specified and no wallpaper/color/mode provided for generation or action."
    show_help
    exit 1
  fi
fi

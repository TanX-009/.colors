#!/bin/bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
CACHE_DIR="$HOME/.cache/colorinator"
RECORD_FILE="$SCRIPT_DIR/generated/record"

# Create the cache directory
mkdir -p "$CACHE_DIR"

# Create and echo empty values in RECORD_FILE
if [ ! -f "$RECORD_FILE" ]; then
	touch "$RECORD_FILE"
	echo "dark|" >"$RECORD_FILE"
fi

# Get previous values
IFS='|' read -r prev_mode prev_wall <"$RECORD_FILE"

# Default values
mode=$prev_mode
automode=false
switchmode=false
relaunch_only=false
wallpaper=""
hexcolor=""
directory=""

# Function to display help
show_help() {
	echo "Usage: ${0##*/} [options] [wallpaper]"
	echo
	echo "Options:"
	echo "  -m, --mode [mode]             Mode to use (default: dark)"
	echo "  -M, --automode                Automatically determine mode"
	echo "  -s, --switchmode              Switch between modes"
	echo "  -r, --relaunch                Only relaunch, no generation"
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
	-r | --relaunch)
		relaunch_only=true
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

# if relaunch only relaunch with previous values
if $relaunch_only; then
	~/.scripts/reload/reload.bash -w "$prev_wall" -m "$prev_mode"
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
	random_wallpaper=$(find "$directory" -type f | shuf -n 1)
	if [ -n "$random_wallpaper" ]; then
		wall=$(realpath "$random_wallpaper")
	else
		echo "Error: Random selected wallpaper \"$wall\" doesn't exist!"
	fi
fi

# Determine mode automatically if automode is set
if [[ $automode == true ]] && [[ -z "$wallpaper" ]] && [[ -z $directory ]]; then
	echo "Error: can't pass -M|--automode flag without passing wallpaper or directory path!"
	show_help
	exit 1
elif [[ $automode == true ]]; then
	if [ -x "$SCRIPT_DIR/utils/isDark.bash" ]; then
		mode=$("$SCRIPT_DIR/utils/isDark.bash" "$wall")
	else
		echo "Error: isDark.bash not found or isn't executable!"
		exit 1
	fi
fi

# Create cache directory
mkdir -p "$CACHE_DIR"

# Navigate to script directory
cd "$SCRIPT_DIR"/colorinator || exit

if $switchmode; then
	if [[ "$prev_mode" == "light" ]]; then
		mode="dark"
	else
		mode="light"
	fi
	wall=$prev_wall
fi

# Generate colors
if [ -n "$wall" ] || [ -n "$directory" ]; then
	python3 main.py -G -i "$wall" -m "$mode" >"$CACHE_DIR"/thex.log 2>&1
	echo "$mode|$wall" >"$RECORD_FILE"
elif [ -n "$hexcolor" ]; then
	python3 main.py -G -c "$hexcolor" -m "$mode" >"$CACHE_DIR"/thex.log 2>&1
fi

# Launch or reload necessary components
~/.scripts/reload/reload.bash -w "$wall" -m "$mode"

#!/bin/bash

mkdir -p .cache
wall=$(realpath "$1")
scriptDir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

cd "$scriptDir"/thex || exit
python3 main.py -G -i "$wall"

isDark=$(vips avg "$wall")
echo "$isDark"

~/.scripts/reload/launch-waybar.bash >.cache/waybar.log 2>&1
~/.scripts/reload/launch-swaybg.bash "$wall" >.cache/swaybg.log 2>&1
~/.scripts/reload/apply-ptm.bash >.cache/terminal.log 2>&1
~/.scripts/reload/apply-swaync.bash >.cache/swaync.log 2>&1
~/.scripts/reload/apply-gradience.bash >.cache/gradience.log 2>&1

#!/bin/bash

mkdir -p .cache
wall="$1"

cd thex || exit
python3 main.py -G -i "$wall"
cd ..

~/.scripts/reload/launch-waybar.bash >.cache/waybar.log 2>&1
~/.scripts/reload/launch-swaybg.bash "$wall" >.cache/swaybg.log 2>&1
~/.scripts/reload/apply-ptm.bash >.cache/terminal.log 2>&1
~/.scripts/reload/apply-swaync.bash >.cache/swaync.log 2>&1
~/.scripts/reload/apply-gradience.bash >.cache/gradience.log 2>&1

#!/bin/bash

mkdir -p .cache
wall="$1"

cd thex || exit
python3 main.py -G -i "$wall"
cd ..

~/.dotfiles.config/.scripts/misc/launch-waybar.sh >.cache/waybar.log 2>&1
~/.dotfiles.config/.scripts/misc/launch-swaybg.bash "$wall" >.cache/swaybg.log 2>&1
~/.dotfiles.config/.scripts/misc/apply-ptm.bash >.cache/terminal.log 2>&1
~/.dotfiles.config/.scripts/misc/apply-gradience.bash >.cache/gradience.log 2>&1

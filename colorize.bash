#!/bin/bash

mkdir -p .cache
wall="$1"

cd thex || exit
python3 main.py -G -i "$wall"
cd ..

~/.dotfiles.config/.scripts/misc/launch-waybar.sh >.cache/waybar.log 2>&1
~/.dotfiles.config/.scripts/misc/launch-swaybg.sh "$wall" >.cache/swaybg.log 2>&1
~/.dotfiles.config/.scripts/misc/apply-ptm.sh >.cache/terminal.log 2>&1

#!/bin/bash

wall="$HOME/.wallpapers/pixel_big_city.png"

swaybg -m fill -i "$wall" &

raw_colors_file_location='./.cache/raw_colors_material.txt'

mkdir -p ./.cache
./generate_colors_material.py --path "$wall" \
	--termscheme ./templates/scheme-base.json \
	--term_fg_boost 0.1 \
	--mode 'dark' \
	--blend_bg_fg \
	>$raw_colors_file_location

mkdir -p ../hyprland
mkdir -p ../gtk
mkdir -p ../foot
mkdir -p ../scss
mkdir -p ../lua
mkdir -p ../terminal
# generate colors and aply using python
./parse.py $raw_colors_file_location

# generate colors and apply using bash
# ./parse.bash

~/.dotfiles.config/.scripts/misc/launch-waybar.sh

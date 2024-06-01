#!/bin/bash

raw_colors_file_location='./.cache/raw_colors_material.txt'

mkdir -p ./.cache
./generate_colors_material.py --path "$HOME/.wallpapers/beautiful_anime_street_scenery_cherry_blossom_kimono_uhdpaper_com.jpg" \
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
# generate colors and aply using python
./parse.py $raw_colors_file_location

# generate colors and apply using bash
./parse.bash

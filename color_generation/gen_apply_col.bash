#!/bin/bash

raw_colors_file_location='./.cache/raw_colors_material.txt'

mkdir -p ./.cache
./generate_colors_material.py --color '#00aacc' \
	--termscheme ./templates/scheme-base.json \
	--mode 'dark' \
	--blend_bg_fg \
	>$raw_colors_file_location

mkdir -p ../hyprland
mkdir -p ../gtk
mkdir -p ../foot
mkdir -p ../scss
# generate colors and aply using python
./parse.py $raw_colors_file_location

# generate colors and apply using bash
./parse.bash

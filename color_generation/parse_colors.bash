#!/bin/bash

raw_colors_file_location='./.cache/raw_colors_material.txt'

mkdir -p ./.cache
./generate_colors_material.py --color '#ebbcba' --mode 'dark' >$raw_colors_file_location

mkdir -p ../hyprland
mkdir -p ../gtk
# generate colors for hyprland
./parse.py $raw_colors_file_location

#!/bin/bash

raw_colors_file_location='./.cache/raw_colors_material.txt'

mkdir -p ./.cache
./generate_colors_material.py --color '#ff00ff' >$raw_colors_file_location

mkdir -p ../hyprland
mkdir -p ../gtk
# generate colors for hyprland
./parser.py $raw_colors_file_location

#!/usr/bin/env python3

import sys
from pathlib import Path
from parsers.terminal import parse_terminal_colors
from parsers.foot import parse_foot_colors

# Check if the script received the correct number of arguments
if len(sys.argv) != 2:
    print("Usage: python script_name.py <file_path>")
    sys.exit(1)

# Get the file path from the first argument
raw_colors_file = sys.argv[1]

# Initialize an empty list to hold the lines
colors = {}

# Open the file and read lines
try:
    with open(raw_colors_file, "r") as file:
        for line in file:
            # Split the line into key-value pair
            key, value = line.strip().split(" ")
            # Store the pair in the dictionary
            colors[key] = value
except FileNotFoundError:
    print(f"Error: File '{raw_colors_file}' not found.")
    sys.exit(1)


hyprland_colors_file = Path("../hyprland/colors.conf")
gtkCSS_file = Path("../gtk/colors.css")
scss_file = Path("../scss/colors.scss")
lua_file = Path("../lua/colors.lua")

try:
    # Now, `lines` is a list where each element is a line from the file
    with open(hyprland_colors_file, "w") as hyprconf, open(
        gtkCSS_file, "w"
    ) as gtkcss, open(scss_file, "w") as scss, open(lua_file, "w") as lua:
        # prep files for writing
        lua.write("return {\n")
        # iterate over the colors except the first two lines
        for index, (key, value) in enumerate(colors.items()):
            if index > 1:
                # write the color to the hyprland.conf file
                hyprconf.write("$" + key + value.replace("#", " = rgba(") + "FF)\n")
                # write the color to the colors.css file for gtk css
                gtkcss.write("@define-color " + key + " " + value + ";\n")
                # write the color to the colors.css file for gtk css
                lua.write("  " + key + ' = "' + value + '",\n')

            # write the color to the colorss.css file for SCSS
            scss.write("$" + key + ": " + value + ";\n")
        # finish started prep
        lua.write("}")
except FileNotFoundError:
    print(f"Error: File(s) '{hyprland_colors_file}/{gtkCSS_file}' not found.")
    sys.exit(1)

# parse_foot_colors(colors)
parse_terminal_colors(colors)

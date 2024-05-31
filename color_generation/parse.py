#!/usr/bin/env python3

import sys
from parsers.foot import parse_foot_colors

# Check if the script received the correct number of arguments
if len(sys.argv) != 2:
    print("Usage: python script_name.py <file_path>")
    sys.exit(1)

# Get the file path from the first argument
raw_colors_file = sys.argv[1]

# Initialize an empty list to hold the lines
rawLines = {}

# Open the file and read lines
try:
    with open(raw_colors_file, "r") as file:
        for line in file:
            # Split the line into key-value pair
            key, value = line.strip().split(" ")
            # Store the pair in the dictionary
            rawLines[key] = value
except FileNotFoundError:
    print(f"Error: File '{raw_colors_file}' not found.")
    sys.exit(1)

colors = rawLines
colors.pop("darkmode")
colors.pop("transparent")

hyprland_colors_file = "../hyprland/colors.conf"
gtkCSS_file = "../gtk/colors.css"

try:
    # Now, `lines` is a list where each element is a line from the file
    with open(hyprland_colors_file, "w") as hyprconf, open(gtkCSS_file, "w") as gtkcss:
        # iterate over the colors except the first two lines
        for key, value in colors.items():
            # write the color to the hyprland.conf file
            hyprconf.write("$" + key + value.replace("#", " = rgba(") + "ff)\n")
            # write the color to the colors.css file for gtk css
            gtkcss.write("@define-color " + key + " " + value + ";\n")
except FileNotFoundError:
    print(f"Error: File(s) '{hyprland_colors_file}/{gtkCSS_file}' not found.")
    sys.exit(1)

parse_foot_colors(colors)

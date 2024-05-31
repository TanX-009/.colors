#!/usr/bin/env python3

import sys

# Check if the script received the correct number of arguments
if len(sys.argv) != 2:
    print("Usage: python script_name.py <file_path>")
    sys.exit(1)

# Get the file path from the first argument
file_path = sys.argv[1]

# Initialize an empty list to hold the lines
lines = []

# Open the file and read lines
try:
    with open(file_path, "r") as file:
        lines = file.readlines()
except FileNotFoundError:
    print(f"Error: File '{file_path}' not found.")
    sys.exit(1)

# Optionally, strip the newline characters from each line
lines = [line.strip() for line in lines]

# Now, `lines` is a list where each element is a line from the file
with open("../hyprland/colors.conf", "w") as hyprconf, open(
    "../gtk/colors.css", "w"
) as gtkcss:
    # iterate over the colors except the first two lines
    for line in lines[2:]:
        # write the color to the hyprland.conf file
        hyprconf.write("$" + line.replace(" ", " = ").replace("#", "rgba(") + "ff)\n")
        # write the color to the colors.css file for gtk css
        gtkcss.write("@define-color " + line + ";\n")

#!/usr/bin/env python3

import sys


def parse_single_color(key, value):
    return f"{key}={value.replace('#', '')}\n"


def generate_foot_colors(colors):
    foot_colors_file = "../generated/foot/colors"
    try:
        with open(foot_colors_file, "w") as foot_colors:
            foot_colors.write("# -*- conf -*-\n")
            foot_colors.write("\n")

            foot_colors.write("[cursor]\n")
            foot_colors.write(
                f"color={colors["surfaceVariant"].replace("#", "")} {colors["onSurface"].replace("#", "")}\n"
            )
            foot_colors.write("\n")

            foot_colors.write("[colors]\n")
            foot_colors.write(parse_single_color("background", colors["surface"]))
            foot_colors.write(parse_single_color("foreground", colors["onSurface"]))
            foot_colors.write(
                parse_single_color("regular0", colors["surfaceContainerLowest"])
            )
            foot_colors.write(parse_single_color("regular1", colors["red"]))
            foot_colors.write(parse_single_color("regular2", colors["green"]))
            foot_colors.write(parse_single_color("regular3", colors["orange"]))
            foot_colors.write(parse_single_color("regular4", colors["deeppurple"]))
            foot_colors.write(parse_single_color("regular5", colors["purple"]))
            foot_colors.write(parse_single_color("regular6", colors["blue"]))
            foot_colors.write(parse_single_color("regular7", colors["bluegrey"]))

            foot_colors.write(parse_single_color("bright0", colors["onSurfaceVariant"]))
            foot_colors.write(parse_single_color("bright1", colors["pink"]))
            foot_colors.write(parse_single_color("bright2", colors["lightgreen"]))
            foot_colors.write(parse_single_color("bright3", colors["yellow"]))
            foot_colors.write(parse_single_color("bright4", colors["lightblue"]))
            foot_colors.write(parse_single_color("bright5", colors["indigo"]))
            foot_colors.write(parse_single_color("bright6", colors["cyan"]))
            foot_colors.write(parse_single_color("bright7", colors["grey"]))
    except FileNotFoundError:
        print(f"Error: File '{foot_colors_file}' not found.")
        sys.exit(1)

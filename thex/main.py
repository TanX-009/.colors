#!/usr/bin/env python3
import argparse
import sys

from generators.raw import generate_raw_colors
from generators.terminal import generate_terminal_colors
from generators.misc import generate_misc_colors


def main(args):
    if args.generate_all:
        colors = generate_raw_colors("~/.wallpapers/manga.png", file=True)
        generate_terminal_colors(colors)
        generate_misc_colors(colors, "../gtk/colors.css", "@define-color $__$ #__#;")
        generate_misc_colors(
            colors, "../lua/colors.lua", '  $__$ = "#__#",', pre="return {", post="}"
        )
        generate_misc_colors(
            colors, "../hyprland/colors.conf", "$$__$ = #__#ff)", replace_hash="rgba("
        )
        generate_misc_colors(colors, "../scss/colors.scss", "$$__$: #__#;", True, True)

    if args.apply_all:
        print("Applying all themes")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Material Theme Generator and Applier")
    parser.add_argument(
        "-G",
        "--generate-all",
        action="store_true",
        default=False,
        help="Generate all files",
    )
    parser.add_argument(
        "-A",
        "--apply-all",
        action="store_true",
        default=False,
        help="Apply all themes",
    )

    args = parser.parse_args()

    if len(sys.argv) == 1:  # No arguments provided
        parser.print_usage()
        sys.exit(1)

    main(args)

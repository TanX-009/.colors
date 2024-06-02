#!/usr/bin/env python3
import argparse
import sys

from generators.raw import generate_raw_colors
from generators.terminal import generate_terminal_colors
from generators.misc import generate_misc_colors


def main(args, parser):
    if args.generate_all:
        if args.image:
            colors = generate_raw_colors(args.image, file=True)
        elif args.color:
            colors = generate_raw_colors(color=args.color, file=True)
        else:
            print("No color or image provided")
            parser.print_usage()
            sys.exit(1)

        # generate terminal colors
        generate_terminal_colors(colors)
        # generate gtkcss colors
        generate_misc_colors(colors, "../gtk/colors.css", "@define-color $__$ #__#;")
        # generate neovim colors
        generate_misc_colors(
            colors, "../lua/colors.lua", '  $__$ = "#__#",', pre="return {", post="}"
        )
        # generate hyprland colors
        generate_misc_colors(
            colors, "../hyprland/colors.conf", "$$__$ = #__#ff)", replace_hash="rgba("
        )
        # generate scss colors
        generate_misc_colors(colors, "../scss/colors.scss", "$$__$: #__#;", True, True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Material Theme Generator and Applier")
    parser.add_argument(
        "-G",
        "--generate-all",
        action="store_true",
        default=False,
        help="Generate all files",
    )
    img_color_group = parser.add_mutually_exclusive_group(required=True)
    img_color_group.add_argument(
        "-i",
        "--image",
        type=str,
        help="Image to use if generating colors from an image",
    )
    img_color_group.add_argument(
        "-c",
        "--color",
        type=str,
        help="Color to use if generating colors from an color",
    )

    args = parser.parse_args()

    if len(sys.argv) == 1:  # No arguments provided
        parser.print_usage()
        sys.exit(1)

    main(args, parser)

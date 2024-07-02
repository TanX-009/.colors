#!/usr/bin/env python3
import argparse
import os
import sys

from generators.kvantum import generate_kvantum_colors
from generators.raw import generate_raw_colors
from generators.terminal import generate_terminal_colors
from generators.misc import generate_misc_colors
from generators.gradience import generate_gradience_colors
from generators.icons import generate_icons

# TO-DO
# Add arg -g, --generate "list, of, colors, to, generate"


def main(args, parser):
    if args.generate_all:
        if args.image:
            colors = generate_raw_colors(
                args.image, mode=args.mode, file=True, scheme="monochrome"
            )
        elif args.color:
            colors = generate_raw_colors(color=args.color, mode=args.mode, file=True)
        else:
            print("No color or image provided")
            parser.print_usage()
            sys.exit(1)

        # generate terminal colors
        generate_terminal_colors(colors)
        # generate gtkcss colors
        generate_misc_colors(
            colors, "../generated/gtk/colors.css", "@define-color $__$ #__#;"
        )
        # generate neovim colors
        generate_misc_colors(
            colors,
            "../generated/lua/colors.lua",
            '  $__$ = "#__#",',
            pre="return {",
            post="}",
        )
        # generate hyprland colors
        generate_misc_colors(
            colors,
            "../generated/hyprland/colors.conf",
            "$$__$ = #__#ff)",
            replace_hash="rgba(",
        )
        # generate scss colors
        generate_misc_colors(
            colors, "../generated/scss/colors.scss", "$$__$: #__#;", True, True
        )
        # generate gradience colors
        generate_gradience_colors(colors)
        # generate kvantum colors
        generate_kvantum_colors(colors)
        # generate rasi colors
        generate_misc_colors(
            colors,
            "../generated/rasi/colors.rasi",
            "  $__$ : #__#;",
            pre="* {",
            post="}",
            removeUnderscore=True,
        )
        # generate icons
        generate_icons(colors)


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
    parser.add_argument(
        "-m",
        "--mode",
        type=str,
        default="dark",
        help="Theme mode (light, dark), default dark",
    )

    args = parser.parse_args()

    if len(sys.argv) == 1:  # No arguments provided
        parser.print_usage()
        sys.exit(1)

    main(args, parser)

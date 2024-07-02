import os

from utils.generate_colors_material import generate_color_material


def generate_raw_colors(
    path=None, color=None, mode="dark", scheme="vibrant", file=False, transparent=True
):
    if path is None and color is None:
        raise ValueError("You must provide a path or a color")

    if scheme is "monochrome":
        termscheme = "templates/terminal/scheme-monochrome.json"
    else:
        termscheme = ("templates/terminal/scheme-base.json",)

    raw = generate_color_material(
        path=path,
        color=color,
        mode=mode,
        transparent=transparent,
        scheme=scheme,
        termscheme=termscheme,
        term_fg_boost=0.2,
        blend_bg_fg=True,
    )

    if file:
        # Update the cache path to $HOME/.cache
        cache_dir = os.path.expanduser("~/.cache/colorinator")

        # Create the directory if it doesn't exist
        os.makedirs(cache_dir, exist_ok=True)
        raw_colors_material_path = os.path.join(cache_dir, "raw_colors_material.txt")

        with open(raw_colors_material_path, "w") as file:
            for name, value in raw.items():
                file.write(f"{name} {value}\n")

    return raw

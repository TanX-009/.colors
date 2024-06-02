import os

from utils.generate_colors_material import generate_color_material


def generate_raw_colors(file=False):
    raw = generate_color_material(
        path="~/.wallpapers/saturn-rings.jpg",
        mode="dark",
        termscheme="templates/terminal/scheme-base.json",
        term_fg_boost=0.1,
        blend_bg_fg=True,
    )

    if file:
        cache_dir = ".cache"
        # Create the directory if it doesn't exist
        os.makedirs(cache_dir, exist_ok=True)
        raw_colors_material_path = os.path.join(cache_dir, "raw_colors_material.txt")

        with open(raw_colors_material_path, "w") as file:
            for name, value in raw.items():
                file.write(f"{name} {value}\n")

    return raw

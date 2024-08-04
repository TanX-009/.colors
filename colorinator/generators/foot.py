#!/usr/bin/env python3

from pathlib import Path
import shutil


def generate_foot_colors(colors):
    preset_file = Path("../generated/foot/colors")
    template_file = Path("templates/terminal/foot")

    if not Path(template_file).is_file():
        print("Template file not found for foot. Skipping that.")
        return

    Path(preset_file).parent.mkdir(parents=True, exist_ok=True)
    shutil.copy(template_file, preset_file)

    with open(preset_file, "r") as file:
        preset_content = file.read()

    for key, value in colors.items():
        key_id = "{{ $" + key + " }}"
        stripped_value = str(value).replace("#", "")
        preset_content = preset_content.replace(key_id, stripped_value)

    with open(preset_file, "w") as file:
        file.write(preset_content)

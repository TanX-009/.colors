from pathlib import Path
import shutil


def generate_kvantum_colors(colors):
    svg_file = Path("../generated/kvantum/template.svg")
    svg_template_file = Path("templates/kvantum/template.svg")

    kvconfig_file = Path("../generated/kvantum/template.kvconfig")
    kvconfig_template_file = Path("templates/kvantum/template.kvconfig")

    # Check if template exists
    if (
        not Path(svg_template_file).is_file()
        or not Path(kvconfig_template_file).is_file()
    ):
        print("Template file not found for Kvantum. Skipping that.")
        return

    # ----svg----
    # Create path for svg
    Path(svg_file).parent.mkdir(parents=True, exist_ok=True)
    shutil.copy(svg_template_file, svg_file)

    # Open svg preset file
    with open(svg_file, "r") as file:
        svg_preset_content = file.read()
    # replace with colors
    for key, value in colors.items():
        key_id = "{" + key + "}"
        svg_preset_content = svg_preset_content.replace(key_id, str(value))
    # write modified content
    with open(svg_file, "w") as file:
        file.write(svg_preset_content)

    # ----kvconfig----
    # Create path for kvconfig
    Path(kvconfig_file).parent.mkdir(parents=True, exist_ok=True)
    shutil.copy(kvconfig_template_file, kvconfig_file)

    # Open kvconfig preset file
    with open(kvconfig_file, "r") as file:
        kvconfig_preset_content = file.read()
    # replace with colors
    for key, value in colors.items():
        key_id = "{" + key + "}"
        kvconfig_preset_content = kvconfig_preset_content.replace(key_id, str(value))
    # write modified content
    with open(kvconfig_file, "w") as file:
        file.write(kvconfig_preset_content)

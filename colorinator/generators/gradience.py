from pathlib import Path
import shutil


def generate_gradience_colors(colors):
    preset_file = Path("../generated/gtk/preset.json")
    template_file = Path("templates/gradience/preset.json")

    if not Path(template_file).is_file():
        print("Template file not found for Terminal. Skipping that.")
        return

    Path(preset_file).parent.mkdir(parents=True, exist_ok=True)
    shutil.copy(template_file, preset_file)

    with open(preset_file, "r") as file:
        preset_content = file.read()

    for key, value in colors.items():
        key_id = "{{ $" + key + " }}"
        preset_content = preset_content.replace(key_id, str(value))

    with open(preset_file, "w") as file:
        file.write(preset_content)

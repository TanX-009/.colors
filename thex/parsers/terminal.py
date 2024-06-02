import re
from pathlib import Path
import shutil


def parse_terminal_colors(colors, alpha=100):
    sequences_file = Path("../terminal/sequences.txt")
    template_file = Path("templates/sequences.txt")

    if not Path(template_file).is_file():
        print("Template file not found for Terminal. Skipping that.")
        return

    Path(sequences_file).parent.mkdir(parents=True, exist_ok=True)
    shutil.copy(template_file, sequences_file)

    with open(sequences_file, "r") as file:
        sequences_content = file.read()

    print(sequences_content)
    for key, value in colors.items():
        sequences_content = sequences_content.replace(f"${key} #", value.lstrip("#"))

    sequences_content = sequences_content.replace("$alpha", str(alpha))

    with open(sequences_file, "w") as file:
        file.write(sequences_content)

    for file in Path("/dev/pts").glob("*"):
        if re.match(r"^/dev/pts/[0-9]+$", str(file)):
            try:
                with open(file, "w") as term_file:
                    term_file.write(sequences_content)
            except PermissionError:
                print(f"Permission denied while writing to {file}. Skipping.")

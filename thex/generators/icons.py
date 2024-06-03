from pathlib import Path
import os


def generate_icons(colors):
    directory = Path("templates/icons")
    output_directory = Path("../icons")

    Path(output_directory).mkdir(parents=True, exist_ok=True)

    for root, _, files in os.walk(directory):
        for file_name in files:
            with open(os.path.join(root, file_name), "r") as file:
                file_content = file.read()

            # Step 2: Replace the target string
            if file_name.endswith("_contrast.svg"):
                modified_content = file_content.replace("#ffffff", colors["onPrimary"])
            else:
                modified_content = file_content.replace("#000000", colors["primary"])

            # Step 3: Write the modified content back to the file
            with open(os.path.join(output_directory, file_name), "w") as file:
                file.write(modified_content)

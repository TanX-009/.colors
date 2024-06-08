from pathlib import Path


def generate_misc_colors(
    colors,
    path,
    template,
    darkmode=False,
    transparent=False,
    pre=None,
    post=None,
    name_id="$__$",
    value_id="#__#",
    replace_hash=None,
    removeUnderscore=False,
):
    file_path = Path(path)
    Path(file_path).parent.mkdir(parents=True, exist_ok=True)

    try:
        # Now, `lines` is a list where each element is a line from the file
        with open(file_path, "w") as file:
            if pre is not None:
                file.write(pre + "\n")
            # iterate over the colors except the first two lines
            for name, value in colors.items():
                write = True
                if (name == "darkmode" and not darkmode) or (
                    name == "transparent" and not transparent
                ):
                    write = False
                if write:
                    if replace_hash is not None:
                        value = value.replace("#", replace_hash)
                    if removeUnderscore:
                        name = name.replace("_", "")
                    file.write(
                        template.replace(name_id, name).replace(value_id, str(value))
                        + "\n"
                    )
            if post is not None:
                file.write(post)

    except FileNotFoundError:
        print(f"Error: File(s) '{file_path}' not found, skipping...")
        return

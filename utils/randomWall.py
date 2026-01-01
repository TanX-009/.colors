#!/usr/bin/env python3
import random
import sys
import hashlib
from pathlib import Path

if len(sys.argv) < 3:
    print("Usage: script.py <wallpaper_dir> <cache_dir>")
    sys.exit(1)

wallpaper_dir = Path(sys.argv[1]).resolve()
cache_dir = Path(sys.argv[2]).resolve()
cache_dir.mkdir(parents=True, exist_ok=True)

list_file = cache_dir / "shuffled_list.txt"
index_file = cache_dir / "index.txt"
hash_file = cache_dir / "dir_hash.txt"

EXTS = {".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff"}


def dir_hash():
    h = hashlib.sha256()
    for p in sorted(wallpaper_dir.rglob("*")):
        if p.suffix.lower() in EXTS:
            stat = p.stat()
            h.update(f"{p}{stat.st_mtime_ns}".encode())
    return h.hexdigest()


current_hash = dir_hash()
old_hash = hash_file.read_text().strip() if hash_file.exists() else ""

if current_hash != old_hash:
    wallpapers = [str(p) for p in wallpaper_dir.rglob("*") if p.suffix.lower() in EXTS]
    random.shuffle(wallpapers)
    list_file.write_text("\n".join(wallpapers))
    index_file.write_text("0")
    hash_file.write_text(current_hash)

wallpapers = list_file.read_text().splitlines()
idx = int(index_file.read_text())

selected = wallpapers[idx]
idx = (idx + 1) % len(wallpapers)

index_file.write_text(str(idx))
print(selected)

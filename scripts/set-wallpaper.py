#!/usr/bin/env python3
"""Set a static desktop wallpaper on macOS 14 Sonoma without dynamic video.

Usage:
  ./set-wallpaper.py /path/to/image.heic|png|jpg
  ./set-wallpaper.py --restore
"""
import datetime, os, pathlib, plistlib, subprocess, sys, time

STORE = pathlib.Path.home() / "Library/Application Support/com.apple.wallpaper/Store/Index.plist"
BACKUP_DIR = pathlib.Path.home() / "Library/Application Support/codex-wallpaper"


def kickstart_agent() -> None:
    subprocess.run(
        ["/bin/launchctl", "kickstart", "-k", f"gui/{os.getuid()}/com.apple.wallpaper.agent"],
        check=False,
    )


def backups() -> list[pathlib.Path]:
    return sorted(BACKUP_DIR.glob("Index.plist.*.bak"))


def restore() -> int:
    if not backups():
        print("no backup found", file=sys.stderr)
        return 1
    src = backups()[-1]
    STORE.write_bytes(src.read_bytes())
    kickstart_agent()
    print(f"restored {src}")
    return 0


def set_wallpaper(image: str) -> int:
    img = pathlib.Path(image).expanduser().resolve()
    if not img.is_file():
        print(f"image not found: {img}", file=sys.stderr)
        return 1
    if not STORE.is_file():
        print(f"wallpaper store missing: {STORE}", file=sys.stderr)
        return 1

    raw = STORE.read_bytes()
    root = plistlib.loads(raw)
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)
    backup = BACKUP_DIR / f"Index.plist.{int(time.time())}.bak"
    backup.write_bytes(raw)

    now = datetime.datetime.now()
    config = plistlib.dumps(
        {
            "backgroundColor": {
                "components": [0.2549019607843137, 0.4117647058823529, 0.6666666666666666, 1.0],
                "colorSpace": b"bplist00_\x10\x17kCGColorSpaceGenericRGB\x08\x00\x00\x00\x00\x00\x00\x01\x01\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x22",
            },
            "placement": 1,
        },
        fmt=plistlib.FMT_BINARY,
    )
    choice = {
        "Provider": "com.apple.wallpaper.choice.image",
        "Files": [{"relative": img.as_uri()}],
        "Configuration": config,
    }

    touched = 0
    for top_key in ("SystemDefault", "AllSpacesAndDisplays"):
        top = root.get(top_key)
        if not isinstance(top, dict):
            continue
        for node_key in ("Linked", "Desktop"):
            node = top.get(node_key)
            if not isinstance(node, dict):
                continue
            node.setdefault("Content", {})["Choices"] = [dict(choice)]
            node["Content"]["Shuffle"] = "$null"
            node["LastSet"] = now
            node["LastUse"] = now
            touched += 1

    if touched == 0:
        print("no wallpaper nodes found; store unchanged", file=sys.stderr)
        return 1
    STORE.write_bytes(plistlib.dumps(root, fmt=plistlib.FMT_BINARY, sort_keys=False))
    kickstart_agent()
    print(f"wallpaper set to {img}; backup: {backup}")
    return 0


if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] == "--restore":
        raise SystemExit(restore())
    if len(sys.argv) != 2:
        print(__doc__.strip())
        raise SystemExit(2)
    raise SystemExit(set_wallpaper(sys.argv[1]))

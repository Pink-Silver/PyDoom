#!python3

import sys
sys.path.append ("src")
from cx_Freeze import setup, Executable

# TODO: Proper versioning

versstring = "unknown"

build_exe_options = dict (
    excludes = ["bz2"],
    include_files = [
        ("extern/SDL2-2.0.3/lib/SDL2.dll", ""),
        ("extern/glew-1.11.0/bin/Release/Win32/glew32.dll", "")
        ],
    constants = "GITVERSION={version}".format (version = repr (versstring))
    )

# GUI applications require a different base on Windows (the default is for a
# console application).
base = None
if sys.platform == "win32":
    base = "Win32GUI"

exe = Executable (
    "src/main.py",
    base = base,
    targetName = "PyDoom.exe",
    icon = "Logo.ico"
    )

setup (
    name = "PyDoom",
    version = "0.1",
    description = "A pure port of the game DOOM to the Python scripting language, aiming for maximum flexibility through modding.",
    options = dict (build_exe = build_exe_options),
    executables = [exe]
    )

#!python3

import sys
sys.path.append ("src")
from cx_Freeze import setup, Executable

build_exe_options = dict (packages=[], excludes=[])

# GUI applications require a different base on Windows (the default is for a
# console application).
base = None
if sys.platform == "win32":
    base = "Win32GUI"

# TODO: Proper versioning

setup (
    name = "PyDoom",
    version = "0.1",
    description = "A pure port of the game DOOM to the Python scripting language, aiming for maximum flexibility through modding.",
    options = dict (build_exe = build_exe_options),
    executables = [Executable ("src/main.py", base=base)]
    )

#!python3

import sys
sys.path.append ("src")
from cx_Freeze import setup, Executable

def CheckVersion ():
    import subprocess
    
    process = subprocess.Popen (["git", "describe", "--tags"],
        universal_newlines=True, stdout=subprocess.PIPE)
    outbuf, errbuf = process.communicate ()
    
    if process.returncode != 0 or not outbuf:
        return "unknown"
    
    return outbuf.strip ()

versstring = CheckVersion ()

files_to_copy = [
    ("PyDoomResource.zip", "")
]
if sys.platform == "win32":
    files_to_copy.append (("extern/SDL2-2.0.4/lib/x64/SDL2.dll", ""))
    files_to_copy.append (("extern/glew-2.0.0/bin/Release/x64/glew32.dll", ""))

build_exe_options = dict (
    excludes = ["bz2"],
    include_files = files_to_copy,
    constants = "GITVERSION={version}".format (version = repr (versstring))
    )

# GUI applications require a different base on Windows (the default is for a
# console application).
base = None
target = "PyDoom"
if sys.platform == "win32":
    base = "Win32GUI"
    target = "PyDoom.exe"

exe = Executable (
    "main.py",
    base = base,
    targetName = target,
    icon = "Logo.ico"
    )

setup (
    name = "PyDoom",
    version = "0.1",
    description = "A pure port of the game DOOM to the Python scripting language, aiming for maximum flexibility through modding.",
    options = dict (build_exe = build_exe_options),
    executables = [exe]
    )

#!python3

import shutil
import os
import os.path
import subprocess

if os.path.exists ("build"):
    print ("Removing build directory...")
    shutil.rmtree ("build")

if os.path.exists ("dist"):
    print ("Removing dist directory...")
    shutil.rmtree ("dist")

try:
    print ("Building resource zip...")
    failure = subprocess.call (["python", "MakeZip.py", "resourcezip", "PyDoomResource.zip"])
    if failure or not os.path.exists ("PyDoomResource.zip"):
        raise RuntimeError ("Building the resource zip failed!")

    print ("Building C extensions...")
    failure = subprocess.call (["python", "setup_extensions.py", "build_ext", "--inplace"])
    if failure:
        raise RuntimeError ("Building the C extensions failed!")

    print ("Building executable...")
    failure = subprocess.call (["python", "setup_exe.py", "bdist"])
    if failure:
        raise RuntimeError ("Building the executable failed!")
except RuntimeError as err:
    print (err)
    input ("Press enter to continue.")

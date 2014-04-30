# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

from version import GITVERSION
from time import sleep
from sys import argv, path
import PyDoom_OpenGL
import arguments

def main ():
    print ("=== PyDoom revision {} ===".format (GITVERSION))
    args = arguments.ArgumentParser (argv[1:])
    args.CollectArgs ()
    del args
    PyDoom_OpenGL.CreateWindow ((640, 480), False)
    sleep (2)
    PyDoom_OpenGL.DestroyWindow ()
    sleep (2)
    PyDoom_OpenGL.CreateWindow ((800, 600), False)
    sleep (2)
    PyDoom_OpenGL.DestroyWindow ()

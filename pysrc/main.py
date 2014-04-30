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
import graphics
import resources

def main ():
    print ("=== PyDoom revision {} ===".format (GITVERSION))
    args = arguments.ArgumentParser (argv[1:])
    args.CollectArgs ()
    del args
    PyDoom_OpenGL.CreateWindow ((640, 480), False)
    doom2 = resources.WadFile ("doom2.wad")
    palette = graphics.MakePalettes (doom2.directory[0].data)[0]
    titlepic = graphics.Image.LoadDoomGraphic (doom2.directory[612].data, palette)
    titletex = PyDoom_OpenGL.LoadTexture (titlepic)
    PyDoom_OpenGL.BeginDrawing ()
    PyDoom_OpenGL.Draw2D (titletex, (0, 0, 640, 480))
    PyDoom_OpenGL.FinishDrawing ()
    sleep (5)
    PyDoom_OpenGL.DestroyWindow ()

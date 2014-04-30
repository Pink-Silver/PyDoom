# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

import logging
from logging.handlers import FileHandler

main_log = logging.getLogger ("PyDoom")
main_log.addHandler (FileHandler ("pydoom.log"))

from version import GITVERSION
from time import sleep
from sys import argv, path
import PyDoom_OpenGL
from arguments import ArgumentParser
from graphics import MakePalettes, Image
from resources import WadFile

def main ():
    main_log.info ("=== PyDoom revision {} ===".format (GITVERSION))
    args = ArgumentParser (argv[1:])
    args.CollectArgs ()
    del args
    doom2 = WadFile ("doom2.wad")
    palette = MakePalettes (doom2.ReadLump (doom2.FindFirstLump ("playpal")))[0]
    titlepic = Image.LoadDoomGraphic (doom2.ReadLump (doom2.FindFirstLump ("titlepic")), palette)
    PyDoom_OpenGL.CreateWindow ((640, 480), False)
    titletex = PyDoom_OpenGL.LoadTexture (titlepic)
    PyDoom_OpenGL.BeginDrawing ()
    PyDoom_OpenGL.Draw2D (titletex, (0, 0, 640, 480))
    PyDoom_OpenGL.FinishDrawing ()
    sleep (5)
    PyDoom_OpenGL.DestroyWindow ()

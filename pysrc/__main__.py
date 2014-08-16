# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

import traceback
import logging

# sys.path manipulation
from sys import path
path.insert (0, "PyDoom.zip")
del path

from logging import FileHandler
from pydoom.arguments import ArgumentParser
from pydoom.launcher import selectGame
from pydoom.version import GITVERSION
from sys import argv, exit
from tkinter import Tk
from tkinter.messagebox import showerror

def setupLog ():
    masterlog = logging.getLogger ("PyDoom")
    masterlog.addHandler (FileHandler ("pydoom.log", "w"))
    masterlog.setLevel ("INFO")
    
    return masterlog

## Supported Games ##
import doom2
import doomrlsm
games = [ doom2, doomrlsm ]

def main ():
    global masterlog
    
    masterlog.info ("=== PyDoom revision {} ===".format (GITVERSION))

    args = ArgumentParser (argv[1:])
    args.CollectArgs ()
    width, height = (640, 480)
    fullscreen = False
    if args.resolution[0] is not None:
        width = args.resolution[0]
    if args.resolution[1] is not None:
        height = args.resolution[1]
    if args.fullscreen is not None:
        fullscreen = args.fullscreen
    del args

    game = selectGame (games)
    masterlog.info ("Playing: " + game.game_title)

masterlog = setupLog ()
interp = Tk ()
interp.withdraw ()

try:
    main ()
    interp.destroy ()
    exit (0)
except Exception as err:
    exctext = traceback.format_exc ()
    masterlog.error (exctext)
    showerror (parent=interp, title="PyDoom Error", message=exctext)
    exit (1)

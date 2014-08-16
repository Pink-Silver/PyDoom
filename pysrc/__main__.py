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

masterlog = logging.getLogger ("PyDoom")
masterlog.addHandler (FileHandler ("pydoom.log", "w"))
masterlog.setLevel ("INFO")

from pydoom.arguments import ArgumentParser
from pydoom.launcher import selectGame
from pydoom.version import GITVERSION
from sys import argv, exit
from tkinter import Tk
from tkinter.messagebox import showerror

## Supported Games ##
import doom2
import doomrlsm
games = [ doom2, doomrlsm ]

def main ():
    global masterlog

    masterlog.info ("=== PyDoom revision {} ===".format (GITVERSION))
    if argv[1:]:
        masterlog.info ("Command line: {}".format (' '.join (argv[1:])))

    args = ArgumentParser (argv[1:])
    args.CollectArgs ()
    width, height = (640, 480)
    fullscreen = False
    game = None
    manualgamechoice = False
    if args.resolution[0] is not None:
        width = args.resolution[0]
    if args.resolution[1] is not None:
        height = args.resolution[1]
    if args.fullscreen is not None:
        fullscreen = args.fullscreen
    if args.game is not None:
        for thisgame in games:
            if args.game == thisgame.game_shortname:
                game = thisgame
    del args

    if not game:
        game = selectGame (games)
        manualgamechoice = True
    if not game:
        masterlog.info ("Chose to cancel out; quitting.")
        return

    masterlog.info ("Playing: {}".format (game.game_title))

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

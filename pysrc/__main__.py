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

mainlogfile = logging.FileHandler ("pydoom.log", "w")
mainlogfile.setFormatter (logging.Formatter (style='{',
    fmt='[{levelname:8s}] ({name:13s}) {message}'))

masterlog = logging.getLogger ("PyDoom")
masterlog.addHandler (mainlogfile)
masterlog.setLevel ("INFO")


from pydoom.arguments import ArgumentParser
from pydoom.games import selectGame
from pydoom.version import GITVERSION
from pydoom.configuration import loadSystemConfig
from pydoom.resources import ResourceZip
from sys import argv, exit
from tkinter import Tk
from tkinter.messagebox import showerror

def main ():
    global masterlog

    masterlog.info ("=== PyDoom revision {} ===".format (GITVERSION))
    if argv[1:]:
        masterlog.info ("Command line: {}".format (' '.join (argv[1:])))

    args = ArgumentParser (argv[1:])
    args.CollectArgs ()

    loadSystemConfig ()

    mainResource = ResourceZip ("PyDoomResource.zip")
    games = mainResource.game_modules

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

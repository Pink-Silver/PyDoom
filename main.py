#!python3

# Copyright (c) 2014, Kate Fox
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

import traceback
import logging

# sys.path manipulation
from sys import stdout

mainlogformat = logging.Formatter (style='{',
    fmt='[{levelname:8s}] ({name:13s}) {message}')
    
mainlogfile = logging.FileHandler ("pydoom.log", "w")
mainlogfile.setFormatter (mainlogformat)

mainlogconsole = logging.StreamHandler (stdout)
mainlogconsole.setFormatter (mainlogformat)

masterlog = logging.getLogger ("PyDoom")
masterlog.setLevel ("INFO")
masterlog.addHandler (mainlogconsole)
masterlog.addHandler (mainlogfile)

from pydoom.arguments import ArgumentParser
GITVERSION = "unknown"
try:
    from BUILD_CONSTANTS import GITVERSION
except ImportError:
    pass
from pydoom.configuration import loadSystemConfig
from pydoom.resources import ResourceZip
from sys import argv, exit
import pydoom.extensions.video as video
import pydoom.extensions.utility as utility

def main ():
    global masterlog
    
    utility.initialize ()

    masterlog.info ("PyDoom revision {}".format (GITVERSION))
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
    
    screen = video.OpenGLInterface ("PyDoom".encode ("utf8"), width, height, fullscreen, False)
    texture = video.ImageSurface ("SampleTexture".encode ("utf8"), 10, 10)
    
    from time import sleep
    sleep (5)
    
    del screen
    utility.shutdown ()

try:
    main ()
    exit (0)
except Exception as err:
    exctext = traceback.format_exc ()
    masterlog.error (exctext)
    exit (1)

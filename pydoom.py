#!python3

# Copyright (c) 2016, Kate Fox
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

import traceback
import logging

# sys.path manipulation
from sys import stdout

mainlogformat = logging.Formatter (style='{',
    fmt='[{levelname}] ({name}) {message}')
    
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
from pydoom.resources import ResourceArchive
from sys import argv, exit
import pydoom.interface as interface
import pydoom.wadfile as wadfile

def main ():
    global masterlog
    
    interface.ready ()

    masterlog.info ("PyDoom revision {}".format (GITVERSION))
    if argv[1:]:
        masterlog.info ("Command line: {}".format (' '.join (argv[1:])))

    args = ArgumentParser (argv[1:])
    args.CollectArgs ()

    loadSystemConfig ()
    try:
        mainResource = ResourceArchive ("PyDoomResource.zip")
    except FileNotFoundError:
        masterlog.error ("Could not open PyDoomResource.zip!\nIf you're building from source, please run MakeZip.py to build it.")
        exit (1)
    
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
    
    screen = interface.OpenGLWindow ("PyDoom", width, height, fullscreen, False)
    
    iwad = wadfile.WadFile ("games/doom2.wad")
    
    graphic = iwad.FindFirstLump ("TITLEPIC")
    palette = iwad.FindFirstLump ("PLAYPAL")
    gstr = graphic.read()
    pstr = palette.read()
    texture = interface.ImageSurface.LoadDoomGraphic (gstr, pstr)
    
    screen.loadTexture ("TITLEPIC", texture)
    
    prog = screen.compileProgram ("2DBasic", """#version 320 es

precision mediump float;
in vec2 UV;
out vec4 color;
uniform sampler2D sampler;

void main ()
{
    color = texture (sampler, UV).rgba;
}""", """#version 320 es

precision mediump float;
layout (location = 0) in vec2 inPos;
layout (location = 1) in vec2 inUV;
out vec2 UV;

void main ()
{
    vec2 inPos_normal = inPos - vec2 (0.5,0.5);
    inPos_normal /= vec2 (0.5,0.5);
    gl_Position =  vec4 (inPos_normal,0,1);
    
    UV = inUV;
}
""")
    
    screen.useProgram2D ("2DBasic")
    screen.drawHud ("TITLEPIC", 0, 0, 1, 1)
    screen.swap ()
    
    from time import sleep
    sleep (5)
    
    screen.unloadTexture ("TITLEPIC")
    
    del screen
    interface.quit ()

try:
    main ()
    exit (0)
except Exception as err:
    exctext = traceback.format_exc ()
    masterlog.error (exctext)
    exit (1)

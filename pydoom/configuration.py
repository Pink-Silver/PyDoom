# Copyright (c) 2014, Kate Fox
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

import logging

configlog = logging.getLogger ("PyDoom.Config")

from collections import OrderedDict
from configparser import ConfigParser
from sys import argv
from os.path import exists
from os.path import join as joinpath
from os import mkdir, sep

# Dummy to return the current directory, in case we don't know what platform
# we're on.
def findProgramDirectory ():
    """findProgramDirectory () -> str
    Returns the program directory used for searching for configuration
    files."""
    return argv[0].rpartition(sep)[0]

def loadSystemConfig ():
    global configlog

    configdir = findProgramDirectory ()
    gameconfigdir = joinpath (configdir, "games")

    if not exists (gameconfigdir):
        mkdir (gameconfigdir)

    configname = joinpath (configdir, "pydoom.ini")

    config = ConfigParser ()

    config.add_section ('video')
    config.set ('video', 'fullscreen',  'no')
    config.set ('video', 'width',       '640')
    config.set ('video', 'height',      '480')

    if not exists (configname):
        configlog.info ("{} doesn't exist! Creating it.".format (configname))
        config.write (open (configname, 'wt'))
    else:
        configlog.info ("Read settings from {}.".format (configname))
        configfile = open (configname, 'rt')
        config.read_file (configfile)
        configfile.close ()

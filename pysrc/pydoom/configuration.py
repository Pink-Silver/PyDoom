# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

import logging

configlog = logging.getLogger ("PyDoom.Config")

from collections import OrderedDict
from configparser import ConfigParser
from sys import platform
from os.path import exists
from os.path import join as joinpath
from os import mkdir

# Dummy to return the current directory, in case we don't know what platform
# we're on.
findProgramDirectory = lambda: '.'

if platform == 'win32':
    import ctypes
    
    GetModuleFileNameW = ctypes.windll.kernel32.GetModuleFileNameW
    def findProgramDirectory ():
        buffer = ctypes.create_unicode_buffer("", 1025)
        GetModuleFileNameW (ctypes.POINTER(ctypes.c_int)(), buffer, 1024)
        
        progdir = buffer.value
        del buffer
        return progdir.rpartition("\\")[0]

elif platform == 'linux':
    from os.path import expanduser
    
    def findProgramDirectory ():
        configdir = expanduser ("~/pydoom")
        
        if not exists (configdir):
            # On linux, the ~ path may not actually exist at first, so create it
            # now
            mkdir (configdir)
        return configdir

findProgramDirectory.__doc__ = """findProgramDirectory () -> str
    Returns the program directory used for searching for configuration
    files."""

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

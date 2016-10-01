#!python3
#cython: language_level=3

# Copyright (c) 2014, Kate Fox
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

cimport cython
from libc.string cimport strcmp
from libc.stdio cimport sprintf

import pydoom.wadfile

import struct
import logging
import zipfile
import sys
from io import TextIOWrapper
from importlib import import_module
from os.path import join as joinpath

resourcelog = logging.getLogger("PyDoom.Resource")

@cython.cdivision(True)
def MeasureSize (double size):
    """Returns a size in bytes as a human-readable number."""
    cdef const char *suffix = b"B"
    cdef char[8] endstr
    
    cdef (const char *)[4] sizenames = (
        b"TB",
        b"GB",
        b"MB",
        b"KB"
    )

    cdef double[4] sizenumbers = (
        1000 ** 4,
        1000 ** 3,
        1000 ** 2,
        1000
    )
    
    for i in range (4):
        if size / sizenumbers[i] >= 1:
            suffix = sizenames[i]
            size /= sizenumbers[i]
    
    sprintf (endstr, "%.2f%s", size, suffix)
    
    return endstr.decode ("utf8")

class ResourceArchive:
    def __init__ (self, filename):
        self.filename = filename
        self._file = open (filename, "rb")
        self.magic = self._file.read (4)
        self._file.close ()
        del self._file
        self._zip = zipfile.ZipFile (filename)
        
        self.game_modules = self.readGames ()

    def readGames (self):
        games = []
        
        gamelisttxt = None
        try:
            gamelisttxt = self._zip.getinfo ("Games.txt")
        except KeyError:
            pass
        
        if gamelisttxt:
            with TextIOWrapper (self._zip.open (gamelisttxt)) as textfile:
                for line in textfile:
                    modname = line.strip ()
                    try:
                        games.append (self.importModule (modname))
                        resourcelog.info ("Found game module: {}".format (
                            modname))
                    except ImportError:
                        resourcelog.warning (
                            "Unable to load game module: {}".format (modname))
        
        return games
    
    def importModule (self, modulename):
        temp_path = sys.path
        sys.path = [joinpath (self.filename, "scripts")]
        try:
            mod = import_module (modulename)
        finally:
            # We need to restore sys.path regardless of exceptions
            sys.path = temp_path
        return mod

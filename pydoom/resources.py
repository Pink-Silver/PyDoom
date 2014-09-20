# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

import struct
import logging
import pydoom.zipfile_custom as zipfile
import sys
from io import TextIOWrapper
from importlib import import_module
from os.path import join as joinpath

resourcelog = logging.getLogger("PyDoom.Resource")

def MeasureSize (size):
    sizetable = (
        ("TB", 1024 ** 4),
        ("GB", 1024 ** 3),
        ("MB", 1024 ** 2),
        ("KB", 1024),
    )
    
    suffix = "B"
    for i in range (len (sizetable)):
        if size / sizetable[i][1] >= 1:
            suffix = sizetable[i][0]
            size /= sizetable[i][1]
    
    return "{:.2f}{}".format (size, suffix)

def PeekBytes (bytestr):
    """Returns the type of resource archive based on the byte string
    signature."""
    if bytestr[0:4] == b"IWAD" or bytestr[0:4] == b"PWAD":
        return "wad"
    if bytestr[0:2] == b"PK":
        return "zip"
    if bytestr[0:2] == b"7Z":
        return "7z"
    
    return "unknown"

class WadLump:
    def __init__ (self):
        # All this stuff gets set later
        self.name = None
        self.kind = "global"
        self.pos = 0
        self.size = 0
        self.data = None

class WadFile:
    nsmarkers = {
        "S_START": (True,  "sprites"),
        "S_END"  : (False, "sprites"),
        
        "F_START": (True,  "flats"),
        "F_END"  : (False, "flats"),
    }
    def __init__ (self, filename):
        self._file = open (filename, "rb")
        self.magic = self._file.read (4)
        if PeekBytes (self.magic) != "wad":
            self._file.close ()
            raise ValueError ("{} is not a valid WAD file".format (filename))
        
        self.header = self._file.read (8)
        self.numlumps, self.infotableofs = struct.unpack ("<ii", self.header)
        self.directory = []
        
        self._file.seek (self.infotableofs)
        namespace = "global"
        for curlump in range (self.numlumps):
            direntry = WadLump ()
            direntry.pos, direntry.size, direntry.name = struct.unpack ("<ii8s", self._file.read (16))
            
            # Sanitize name
            direntry.name = direntry.name.replace (b"\x00", b"").decode ("ascii", "ignore").upper ()
            
            if direntry.name in self.nsmarkers:
                # Change namespace for further entries
                if self.nsmarkers[direntry.name][0] == True:
                    if namespace != "global":
                        resourcelog.warning ("Spurious {} found inside {} namespace".format (direntry.name, namespace))
                    namespace = self.nsmarkers[direntry.name][1]
                else:
                    if namespace != self.nsmarkers[direntry.name][1]:
                        resourcelog.warning ("Spurious {} found inside {} namespace".format (direntry.name, namespace))
                    namespace = "global"
            
            if direntry.size:
                self.kind = namespace
            
            self.directory.append (direntry)
        
        if namespace != "global":
            resourcelog.warning ("The {} namespace isn't closed".format (namespace))
        
    def __del__ (self):
        self._file.close ()
    
    def FindFirstLump (self, name):
        name = name.upper ()
        for i in range (len (self.directory)):
            if self.directory[i].name == name:
                return i
        
        return None
    
    def FindAllLumps (self, name):
        name = name.upper ()
        
        lumps = []
        for i in range (len (self.directory)):
            if self.directory[i].name == name:
                lumps.append (self.directory[i])
        
        return lumps
    
    def ReadLump (self, index):
        if self._file.closed:
            raise ValueError ("File is closed")
        
        entry = self.directory[index]
        if entry.data is not None:
            return entry.data
        
        self._file.seek (entry.pos)
        try:
            entry.data = self._file.read (entry.size)
        except MemoryError:
            resourcelog.error ("Ran out of memory trying to allocate {} for {}.".format (MeasureSize (entry.size), entry.name))
            raise
        
        return entry.data

class ResourceZip:
    def __init__ (self, filename):
        self.filename = filename
        self._file = open (filename, "rb")
        self.magic = self._file.read (4)
        if PeekBytes (self.magic) != "zip":
            self._file.close ()
            raise ValueError ("{} is not a valid ZIP file".format (filename))
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

# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

import struct
from pydoom.utility import measuresize
import logging

resource_log = logging.getLogger("PyDoom.Resource")

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
                        resource_log.warning ("Spurious {} found inside {} namespace".format (direntry.name, namespace))
                    namespace = self.nsmarkers[direntry.name][1]
                else:
                    if namespace != self.nsmarkers[direntry.name][1]:
                        resource_log.warning ("Spurious {} found inside {} namespace".format (direntry.name, namespace))
                    namespace = "global"
            
            if direntry.size:
                self.kind = namespace
            
            self.directory.append (direntry)
        
        if namespace != "global":
            resource_log.warning ("The {} namespace isn't closed".format (namespace))
        
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
            resource_log.error ("Ran out of memory trying to allocate {} for {}.".format (entry.name, measuresize (entry.size)))
            raise
        
        return entry.data

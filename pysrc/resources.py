# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

import struct

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
        self.pos = 0
        self.size = 0
        self.data = None

class WadFile:
    def __init__ (self, filename):
        self._file = open (filename, "rb")
        self.magic = self._file.read (4)
        if PeekBytes (self.magic) != "wad":
            self._file.close ()
            raise ValueError ("{} is not a valid WAD file".format (filename))
        
        self.header = self._file.read (8)
        self.numlumps, self.infotableofs = struct.unpack ("<ii", self.header)
        self.directory = []
        
        #print ("Reading {} ({}, {} lumps)...".format (filename, self.magic.decode ("ascii", "ignore"), self.numlumps))
        self._file.seek (self.infotableofs)
        curlump = 0
        while curlump < self.numlumps:
            # Read lumps until we can't anymore
            direntry = WadLump ()
            direntry.pos, direntry.size, direntry.name = struct.unpack ("<ii8s", self._file.read (16))
            # Turn the name into something human-readable if it's not, uppercasing it if we need to
            direntry.name = direntry.name.replace (b"\x00", b"").decode ("ascii", "strict").upper ()
            
            self.directory.append (direntry)
            curlump += 1
        
        for item in self.directory:
            #print ("  Lump {} ({} bytes)...".format (item.name, item.size))
            if item.size <= 0:
                continue
            
            self._file.seek (item.pos)
            try:
                item.data = self._file.read (item.size)
            except MemoryError:
                print ("Lump '{}' is a weird size? (Asked for {} bytes)".format (item.name, item.size))
        #print ("Done.")

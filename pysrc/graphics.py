# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

import io
import struct

class PaletteIndex:
    def __init__ (self, red, green, blue):
        self.red   = red
        self.green = green
        self.blue  = blue

    def __str__ (self):
        return "({0}, {1}, {2})".format (self.red, self.green, self.blue)

    def __bytes__ (self):
        return struct.pack ("<BBB", self.red, self.green, self.blue)

class Palette:
    def __init__ (self):
        self.colors = []

def MakePalettes (byteseq):
    pals = []
    numpals = len (byteseq) // 768
    if len (byteseq) % 768 != 0:
        raise ValueError ("Passed a strange-size palette lump")

    pos = 0
    for i in range (numpals):
        pal = Palette ()

        for e in range (256):
            pal.colors.append (PaletteIndex (*struct.unpack ("<BBB", byteseq[pos:pos+3])))
            pos += 3

        pals.append (pal)

    return pals

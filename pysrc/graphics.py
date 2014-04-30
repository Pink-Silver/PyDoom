# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

import io
import struct, array

##### PALETTES #####

class PaletteIndex:
    """Represents a color entry in a 256-color palette."""
    def __init__ (self, red, green, blue):
        self.red   = red
        self.green = green
        self.blue  = blue

    def __str__ (self):
        return "({0}, {1}, {2})".format (self.red, self.green,
            self.blue)

    def __bytes__ (self):
        return struct.pack ("<BBB", self.red, self.green, self.blue)

class Palette:
    """Represents a 256-color palette."""
    def __init__ (self):
        self.colors = []

def MakePalettes (byteseq):
    """Translates a binary PLAYPAL lump into a series of Palettes."""
    pals = []
    numpals = len (byteseq) // 768
    if len (byteseq) % 768 != 0:
        raise ValueError ("Passed a strange-size palette lump")

    pos = 0
    for i in range (numpals):
        pal = Palette ()

        for e in range (256):
            pal.colors.append (PaletteIndex (*struct.unpack ("<BBB",
                byteseq[pos:pos+3])))
            pos += 3

        pals.append (pal)

    return pals

##### IMAGES #####

class Image:
    """An image that stores its' data in an RGBA8-format linear buffer."""
    def __init__ (self, width, height, xofs=0, yofs=0):
        self.dimensions = (width, height)
        self.offsets = (xofs, yofs)
        self._buffer = array.array ('B', b'\x00' * (width * height * 4))

    @classmethod
    def LoadDoomGraphic (cls, bytebuffer, palette):
        """Loads a top-down column-based paletted doom graphic, given the
        graphic's binary data and a palette. Returns an Image usable
        with the OpenGL context."""
        pos = 0

        width, height, xofs, yofs = struct.unpack_from ("<HHHH",
            bytebuffer, pos)
        pos += struct.calcsize ("<HHHH")

        image = cls (width, height, xofs, yofs)

        colheaders = []

        # The headers for each column
        for colheader in range (width):
            colheaders.append (struct.unpack_from ("<I", bytebuffer, pos))
            pos += struct.calcsize ("<I")

        # Okay, so in BOOM's format, if the last row started in the
        # same column is above or at the height last drawn, they'd
        # usually be drawn above or on top of the column we just drew.

        # So the tall patch format takes advantage of this! In such a
        # case, we normally would be drawing above or at the height we
        # were *just* drawing at (which would be a waste of space since
        # we're just drawing on top of pixels we *just* drew).

        # Instead, what we do is *add* the last offset to our current
        # one, so we're always drawing in new space instead. This gives
        # us twice the column height to work with, allowing graphic
        # columns to start from up to the 512th row instead of the
        # 256th. This means transparent images that are > 256 in height
        # won't corrupt.

        for column in range (width):
            lastrowstart = -1
            while True:
                rowstart = struct.unpack_from ("<B", bytebuffer,
                    colheaders[column])

                if rowstart == 255:
                    # No more pieces to draw, go to next column
                    break

                if rowstart <= lastrowstart:
                    rowstart += lastrowstart

                columnlength = struct.unpack_from ("<B", bytebuffer,
                    colheaders[column] + 1)

                for rowpos in range (columnlength):
                    palindex = struct.unpack_from ("<B", bytebuffer,
                        colheaders[column] + 3 + rowpos)

                    palcolor = palette.colors[palindex]
                    image.SetPixel (rowpos, column, palcolor)
                    rowpos += 1

                lastrowstart = rowstart

        return image

    def GetPixel (self, x, y):
        """Retrieves the color of a pixel at the given position."""
        if x < 0 or x >= self.dimensions[0]:
            raise ValueError ("x is out of the image boundary")
        if y < 0 or y >= self.dimensions[1]:
            raise ValueError ("y is out of the image boundary")

        w = self.dimensions[0]
        pixel = self._buffer[((x*4)+(y*w*4)):((x*4)+(y*w*4))+4]
        return (int (pixel[0]), int (pixel[1]), int (pixel[2]),
                int (pixel[3]))

    def SetPixel (self, x, y, color=None):
        """Sets the color of a pixel at the given position."""
        if x < 0 or x >= self.dimensions[0]:
            raise ValueError ("x is out of the image boundary")
        if y < 0 or y >= self.dimensions[1]:
            raise ValueError ("y is out of the image boundary")

        w = self.dimensions[0]
        if color is None:
            color = (0, 0, 0, 0)

        if type (color) is PaletteIndex:
            color = (color.red, color.green, color.blue, 255)

        self._buffer[(x*4)+(y*w*4)+0] = color[0]
        self._buffer[(x*4)+(y*w*4)+1] = color[1]
        self._buffer[(x*4)+(y*w*4)+2] = color[2]
        self._buffer[(x*4)+(y*w*4)+3] = color[3]

    def GetBuffer (self):
        """Returns the underlying binary buffer/array object for this
        image."""
        return self._buffer

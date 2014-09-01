# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free

from video_cpp cimport CScreen

cdef class ImageSurface:
    cdef int width
    cdef int height
    cdef str name
    cdef unsigned char *data
    
    def __init__ (self, str name, int width, int height):
        if width < 1 or height < 1:
            raise ValueError ("Image surface must have a valid width and height")
        
        self.name = name
        self.width = width
        self.height = height
        cdef size_t arraysize = width * height * 4
        
        self.data = <unsigned char *> PyMem_Malloc (arraysize * sizeof (unsigned char))
        
        cdef size_t i = 0
        while i < arraysize:
            self.data[i] = 0
            i += 1
        
        if self.data == NULL:
            raise MemoryError ("Could not allocate memory for surface")
    
    def getPixel (self, int x, int y):
        if x < 0 or y < 0 or x > self.width or y > self.height:
            raise ValueError ("requested x, y out of bounds")
        
        cdef int startofs = ((y * self.width) + x) * 4
        
        cdef unsigned int color = (
            (self.data[startofs]     << 24) +
            (self.data[startofs + 1] << 16) +
            (self.data[startofs + 2] << 8) +
             self.data[startofs + 3]
            )
        
        return color
    
    def setPixel (self, int x, int y, unsigned int color = 0):
        if x < 0 or y < 0 or x > self.width or y > self.height:
            raise ValueError ("requested x, y out of bounds")
        
        cdef int startofs = ((y * self.width) + x) * 4
        
        self.data[startofs]     = (color >> 24) & 0xFF
        self.data[startofs + 1] = (color >> 16) & 0xFF
        self.data[startofs + 2] = (color >>  8) & 0xFF
        self.data[startofs + 3] =  color        & 0xFF
    
    def __del__ (self):
        PyMem_Free (self.data)

cdef class Screen:
    cdef CScreen *ptr
    def __cinit__ (self, str title = "PyDoom", int width = 640, int height = 480,
        bint fullscreen = False, bint fullwindow = False, int display = 0,
        int x = -1, int y = -1):
        
        enctitle = title.encode ("utf-8")
        self.ptr = new CScreen (enctitle, width, height, fullscreen, fullwindow,
            display, x, y)
    
    def __dealloc__ (self):
        del self.ptr
    
    def Shutdown (self):
        self.ptr.Shutdown ()

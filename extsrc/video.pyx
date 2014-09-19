# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free
cimport cvideo

cdef class ImageSurface:
    cdef size_t width
    cdef size_t height
    cdef str name
    cdef unsigned char *data
    
    def __init__ (self, str name, size_t width, size_t height):
        if width < 1 or height < 1:
            raise ValueError ("Image surface must have a valid width and height")
        
        self.name = name
        self.width = width
        self.height = height
        cdef size_t arraysize = width * height * 4
        
        self.data = <unsigned char *> PyMem_Malloc (arraysize * sizeof (unsigned char))
        
        if self.data == NULL:
            raise MemoryError ("Could not allocate memory for surface")
        
        cdef size_t i = 0
        while i < arraysize:
            self.data[i] = 0
            i += 1
    
    cpdef unsigned int getPixel (self, size_t x, size_t y) except? 0:
        if x > self.width or y > self.height:
            raise ValueError ("requested x, y out of bounds")
        
        cdef size_t startofs = ((y * self.width) + x) * 4
        
        cdef unsigned int color = (
            (self.data[startofs]     << 24) +
            (self.data[startofs + 1] << 16) +
            (self.data[startofs + 2] << 8) +
             self.data[startofs + 3]
            )
        
        return color
    
    cpdef setPixel (self, size_t x, size_t y, unsigned int color = 0):
        if x > self.width or y > self.height:
            raise ValueError ("requested x, y out of bounds")
        
        cdef size_t startofs = ((y * self.width) + x) * 4
        
        self.data[startofs]     = (color >> 24) & 0xFF
        self.data[startofs + 1] = (color >> 16) & 0xFF
        self.data[startofs + 2] = (color >>  8) & 0xFF
        self.data[startofs + 3] =  color        & 0xFF
    
    def __del__ (self):
        PyMem_Free (self.data)

def initialize (str title = "PyDoom", int width = 640, int height = 480,
    bint fullscreen = False, bint fullwindow = False, int display = 0,
    int x = -1, int y = -1):
    
    enctitle = title.encode ("utf-8")
    
    cdef int success = cvideo.vid_initialize (enctitle, width, height,
        fullscreen, fullwindow, display, x, y)
    if not success:
        raise RuntimeError ()

def shutdown ():
    cvideo.vid_shutdown ()

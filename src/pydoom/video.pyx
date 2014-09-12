# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free
from video_cpp cimport CScreen, CHUDElement
from libcpp.vector cimport vector

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

cdef class Screen:
    cdef CScreen *ptr
    cdef vector[CHUDElement *] hud_elements
    
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
    
    cdef ImageSurface EnlargeTexture (self, ImageSurface image):
        cdef ImageSurface biggerimage = ImageSurface (image.name,
            image.width * 4, image.height * 4)
        
        cdef size_t x = 0
        cdef size_t y = 0
        cdef size_t startofs = 0
        while y < image.height:
            x = 0
            while x < image.width:
                color = image.getPixel (x, y)
                
                biggerimage.setPixel (x * 4,     y * 4,     color)
                biggerimage.setPixel (x * 4 + 1, y * 4,     color)
                biggerimage.setPixel (x * 4 + 2, y * 4,     color)
                biggerimage.setPixel (x * 4 + 3, y * 4,     color)

                biggerimage.setPixel (x * 4,     y * 4 + 1, color)
                biggerimage.setPixel (x * 4 + 1, y * 4 + 1, color)
                biggerimage.setPixel (x * 4 + 2, y * 4 + 1, color)
                biggerimage.setPixel (x * 4 + 3, y * 4 + 1, color)

                biggerimage.setPixel (x * 4,     y * 4 + 2, color)
                biggerimage.setPixel (x * 4 + 1, y * 4 + 2, color)
                biggerimage.setPixel (x * 4 + 2, y * 4 + 2, color)
                biggerimage.setPixel (x * 4 + 3, y * 4 + 2, color)

                biggerimage.setPixel (x * 4,     y * 4 + 3, color)
                biggerimage.setPixel (x * 4 + 1, y * 4 + 3, color)
                biggerimage.setPixel (x * 4 + 2, y * 4 + 3, color)
                biggerimage.setPixel (x * 4 + 3, y * 4 + 3, color)

                x += 1
            
            y += 1
        
        return biggerimage
    
    # Texture binding
    def BindTexture (self, ImageSurface image):
        encname = image.name.lower ().encode ("utf-8")
        cdef ImageSurface enlarged = self.EnlargeTexture (image)
        
        cdef int failure = self.ptr.BindTexture (encname, enlarged.width,
            enlarged.height, enlarged.data)

        if (failure == 1):
            raise RuntimeError ("Could not make OpenGL context current")
    
    def DropTextures (self, list names):
        for tex in names:
            texenc = tex.lower ().encode ("utf-8")
            self.ptr.DropTexture (texenc)

    def ClearTextures (self):
        self.ptr.ClearTextures ()
    
    # Drawing
    def Update (self):
        self.ptr.DrawClear ()
        self.ptr.DrawHUD (self.hud_elements)
        self.ptr.DrawSwapBuffer ()

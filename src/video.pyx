# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

from sdl.SDL_video cimport *
from sdl.SDL_error cimport SDL_GetError, SDL_ClearError

from libc.stdlib cimport calloc, free

from utility cimport makeTexture, GL_GenerateMipmap_Func

cdef class ImageSurface:
    cdef int width
    cdef int height
    cdef unsigned char *data
    
    def __init__ (self, int width, int height):
        if self.width < 1 or self.height < 1:
            raise ValueError ("Image surface must have a valid width and height")
        
        self.width = width
        self.height = height
        
        self.data = <unsigned char *>calloc (width * height * 4,
            sizeof (unsigned char))
        
        if self.data == NULL:
            raise MemoryError ("Could not allocate memory for surface")
    
    def getPixel (self, int x, int y):
        if x < 0 or y < 0 or x > self.width or y > self.height:
            raise ValueError ("requested x, y out of bounds")
        
        cdef int startofs = ((y * self.width) + x) * 4
        
        return (self.data[startofs], self.data[startofs + 1],
            self.data[startofs + 2], self.data[startofs + 3])
    
    def setPixel (self, int x, int y, unsigned char red, unsigned char green,
        unsigned char blue, unsigned char alpha):
        if x < 0 or y < 0 or x > self.width or y > self.height:
            raise ValueError ("requested x, y out of bounds")
        
        cdef int startofs = ((y * self.width) + x) * 4
        
        self.data[startofs] = red
        self.data[startofs + 1] = green
        self.data[startofs + 2] = blue
        self.data[startofs + 3] = alpha
    
    def __del__ (self):
        free (self.data)

cdef class Screen:
    cdef dict textures
    cdef SDL_Window * window
    cdef SDL_GLContext context
    cdef GL_GenerateMipmap_Func glGenerateMipmap_ptr
    
    def __init__ (self, str title = "PyDoom", int width = 640, int height = 480,
        bint fullscreen = False, bint fullwindow = False, int x = -1,
        int y = -1):
        
        self.textures = {}
        
        SDL_GL_SetAttribute (SDL_GL_RED_SIZE, 8)
        SDL_GL_SetAttribute (SDL_GL_GREEN_SIZE, 8)
        SDL_GL_SetAttribute (SDL_GL_BLUE_SIZE, 8)
        SDL_GL_SetAttribute (SDL_GL_ALPHA_SIZE, 8)
        SDL_GL_SetAttribute (SDL_GL_MULTISAMPLEBUFFERS, 1)
        SDL_GL_SetAttribute (SDL_GL_MULTISAMPLESAMPLES, 2)
        SDL_GL_SetAttribute (SDL_GL_CONTEXT_MAJOR_VERSION, 3)
        SDL_GL_SetAttribute (SDL_GL_CONTEXT_MINOR_VERSION, 3)
        SDL_GL_SetAttribute (SDL_GL_CONTEXT_PROFILE_MASK,
            SDL_GL_CONTEXT_PROFILE_CORE)
        
        cdef int flags = SDL_WINDOW_OPENGL
        
        if x < 0:
            x = SDL_WINDOWPOS_CENTERED
        if y < 0:
            y = SDL_WINDOWPOS_CENTERED
        
        if fullscreen:
            flags |= SDL_WINDOW_FULLSCREEN
        elif fullwindow:
            flags |= SDL_WINDOW_FULLSCREEN_DESKTOP
        
        enctitle = title.encode ('utf-8')
        self.window = SDL_CreateWindow (enctitle, x, y, width, height, flags)
        del enctitle
        
        if self.window == NULL:
            errmsg = SDL_GetError ()
            SDL_ClearError ()
            errmsg = errmsg.decode ('utf-8')
            raise RuntimeError ("Could not create SDL window: {}".format (errmsg))
        
        self.context = SDL_GL_CreateContext (self.window)
        
        if self.context == NULL:
            errmsg = SDL_GetError ()
            SDL_ClearError ()
            errmsg = errmsg.decode ('utf-8')
            raise RuntimeError ("Could not create OpenGL context: {}".format (errmsg))
        
        self.glGenerateMipmap_ptr = <GL_GenerateMipmap_Func>SDL_GL_GetProcAddress ("glGenerateMipmap")
        
        if self.glGenerateMipmap_ptr == NULL:
            raise RuntimeError ("Could not find the glGenerateMipmap function")

    def __del__ (self):
        self.shutdown ()
    
    def shutdown (self):
        if self.window == NULL:
            return
        
        SDL_GL_DeleteContext (self.context)
        SDL_DestroyWindow (self.window)
        self.context = NULL
        self.window = NULL
        
        self.textures.clear ()
    
    def bindTexture (self, str name, ImageSurface image):
        if self.window == NULL:
            raise RuntimeError ("Cannot bind texture after shutdown")
        
        if name in self.textures:
            return # Texture is already in the array.
        
        cdef unsigned int newtex = makeTexture (self.window, self.context,
            image.width, image.height, image.data, self.glGenerateMipmap_ptr)
        
        self.textures[name] = newtex

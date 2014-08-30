# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

from sdl.SDL_video cimport *
from sdl.SDL_error cimport SDL_GetError, SDL_ClearError

from utility cimport makeTexture

cdef class Screen:
    cdef list textures
    cdef SDL_Window * window
    cdef SDL_GLContext context
    
    def __init__ (self, str title = "PyDoom", int width = 640, int height = 480,
        bint fullscreen = False, bint fullwindow = False, int x = -1,
        int y = -1):
        
        self.textures = []
        
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

    def __del__ (self):
        self.shutdown ()
    
    def shutdown (self):
        SDL_GL_DeleteContext (self.context)
        SDL_DestroyWindow (self.window)
        self.context = NULL
        self.window = NULL
        
        self.textures.clear ()
    
    def bindTexture (self, str name, int width, int height, data):
        pass

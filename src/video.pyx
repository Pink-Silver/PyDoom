# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

cdef extern from "SDL_opengl.h":
    const int SDL_GL_RED_SIZE
    const int SDL_GL_GREEN_SIZE
    const int SDL_GL_BLUE_SIZE
    const int SDL_GL_ALPHA_SIZE
    const int SDL_GL_MULTISAMPLEBUFFERS
    const int SDL_GL_MULTISAMPLESAMPLES
    const int SDL_GL_CONTEXT_PROFILE_MASK
    const int SDL_GL_CONTEXT_PROFILE_CORE
    const int SDL_GL_CONTEXT_MAJOR_VERSION
    const int SDL_GL_CONTEXT_MINOR_VERSION
    
    int __cdecl SDL_GL_SetAttribute (unsigned int attr, int value)

cdef extern from "SDL.h":
    const int SDL_WINDOWPOS_CENTERED
    const int SDL_WINDOW_FULLSCREEN
    const int SDL_WINDOW_FULLSCREEN_DESKTOP
    
    ctypedef struct SDL_Window:
        pass
    SDL_Window * __cdecl SDL_CreateWindow (const char *title,
        int x, int y, int w, int h, unsigned int flags)

# Force C header generation
cdef public void pyvideo_dummyfunc ():
    pass

cdef class Screen:
    cdef list textures
    cdef SDL_Window * window
    
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
        
        cdef int flags = 0
        
        if x < 0:
            x = SDL_WINDOWPOS_CENTERED
        if y < 0:
            y = SDL_WINDOWPOS_CENTERED
        
        if fullscreen:
            flags &= SDL_WINDOW_FULLSCREEN
        elif fullwindow:
            flags &= SDL_WINDOW_FULLSCREEN_DESKTOP
        
        enctitle = title.encode ('utf-8')
        self.window = SDL_CreateWindow (enctitle, x, y, width, height, 0)
        del enctitle
        
        if self.window == NULL:
            raise RuntimeError ("Could not create SDL window")

    def shutdown (self):
        self.textures.clear ()

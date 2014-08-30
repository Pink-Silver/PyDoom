# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

from sdl.SDL_video cimport SDL_Window, SDL_GLContext

cdef extern from "utilityfuncs.hpp":
    ctypedef void (__stdcall *GL_GenerateMipmap_Func)(unsigned int)

    unsigned int makeTexture (SDL_Window *owner, SDL_GLContext context,
        int width, int height, unsigned char *data,
        GL_GenerateMipmap_Func glGenerateMipmap_ptr) except 0

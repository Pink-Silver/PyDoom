// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

#ifndef UTILFUNCS_HPP
#define UTILFUNCS_HPP

// GL API stuff
typedef void (__stdcall *GL_GenerateMipmap_Func)(unsigned int);

extern "C" unsigned int makeTexture (SDL_Window *owner, SDL_GLContext context,
    int width, int height, unsigned char *data,
    GL_GenerateMipmap_Func glGenerateMipmap_ptr);

#endif // UTILFUNCS_HPP

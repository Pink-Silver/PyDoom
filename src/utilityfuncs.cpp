// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

#include "global.hpp"
#include "utilityfuncs.hpp"

unsigned int makeTexture (SDL_Window *owner, SDL_GLContext context, int width,
    int height, unsigned char *data, GL_GenerateMipmap_Func glGenerateMipmap_ptr)
{
    // Image data is assumed provided to us as RGBA8.

    int success = SDL_GL_MakeCurrent (owner, context);

    if (!success)
        return 0;

    GLuint lastTexture = 0;
    glGetIntegerv (GL_TEXTURE_BINDING_2D, (GLint*) &lastTexture);

    GLuint newtex;

    glGenTextures (1, &newtex);
    glBindTexture (GL_TEXTURE_2D, newtex);

    glPixelStorei (GL_UNPACK_ALIGNMENT, 1);
    glTexImage2D (GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_RGBA,
        GL_UNSIGNED_BYTE, data);
    glTexEnvi (GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

    glGenerateMipmap_ptr (GL_TEXTURE_2D);
    glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
        GL_LINEAR_MIPMAP_LINEAR);

    glBindTexture (GL_TEXTURE_2D, lastTexture);

    return newtex;
}

// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

#ifndef VIDEO_HPP
#define VIDEO_HPP

#include "global.hpp"
#include <map>

// GL API stuff
typedef void (APIENTRY *GL_GenerateMipmap_Func)(GLuint);

class CScreen
{
    std::map<std::string, GLuint> textures;
    SDL_Window *window;
    SDL_GLContext context;
    GL_GenerateMipmap_Func glGenerateMipmap_ptr;
public:
    CScreen (std::string name, int width, int height, int fullscreen,
        int fullwindow, int display, int x, int y);
    ~CScreen ();
    
    void Shutdown ();
    int BindTexture (std::string name, int width, int height,
        const unsigned char *data);
    void DropTexture (std::string name);
    void ClearTextures ();
};

#endif // VIDEO_HPP

// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

#ifndef VIDEO_HPP
#define VIDEO_HPP

#include "global.hpp"
#include <map>
#include <vector>

// GL API stuff
typedef void (APIENTRY *GL_GenerateMipmap_Func)(GLenum);

struct CHUDElement;

class CScreen
{
    std::map<std::string, GLuint> textures;
    SDL_Window *window;
    SDL_GLContext context;
    
    // OpenGL 3 functions
    GL_GenerateMipmap_Func glGenerateMipmap_ptr;
    
public:
    CScreen (std::string name, int width, int height, int fullscreen,
        int fullwindow, int display, int x, int y);
    ~CScreen ();
    
    void Shutdown ();
    
    // Texture binding
    int BindTexture (std::string name, int width, int height,
        const unsigned char *data);
    void DropTexture (std::string name);
    void ClearTextures ();
    
    // Drawing
    void DrawClear ();
    void DrawHUD (std::vector<CHUDElement *> elements);
    void DrawSwapBuffer ();
};

struct CHUDElement
{
    std::string graphic;
    float left, top, width, height;
    float clip_left, clip_top, clip_width, clip_height;
    float angle;
};

#endif // VIDEO_HPP

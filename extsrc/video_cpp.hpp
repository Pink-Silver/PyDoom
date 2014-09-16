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

struct CHUDElement
{
    std::string graphic;
    float left, top, width, height;
    float clip_left, clip_top, clip_width, clip_height;
    float angle;
};

enum ShaderType
{
    SHADER_FRAGMENT,
    SHADER_VERTEX,
    SHADER_GEOMETRY
};

void vid_initialize (std::string, int, int, int, int, int, int, int);
unsigned int vid_compileshader (std::string, int);
unsigned int vid_compileprogram (unsigned int *, unsigned int);
void vid_shutdown ();
int vid_loadtexture (std::string, int, int, const unsigned char *);
void vid_unloadtexture (std::string);
void vid_cleartextures ();
void vid_clearscreen ();
void vid_draw2d (std::string, float, float, float, float);
void vid_swapbuffer ();

#endif // VIDEO_HPP

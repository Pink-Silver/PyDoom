// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

#ifndef VIDEO_H
#define VIDEO_H

enum ShaderType
{
    SHADER_FRAGMENT,
    SHADER_VERTEX,
    SHADER_GEOMETRY
};

int vid_initialize (char *, int, int, int, int, int, int, int);
unsigned int vid_compileshader (char *, int);
unsigned int vid_compileprogram (unsigned int *, unsigned int);
void vid_useprogram (unsigned int program);
void vid_shutdown (void);
unsigned int vid_loadtexture (int, int, const unsigned char *);
void vid_unloadtexture (unsigned int tex);
void vid_clearscreen (void);
void vid_draw2d (unsigned int, float, float, float, float);
void vid_swapbuffer (void);

#endif // VIDEO_H

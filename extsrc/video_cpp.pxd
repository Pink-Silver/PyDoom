# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "video_cpp.hpp":
    cdef struct CHUDElement:
        string graphic
        
        float left
        float top
        float width
        float height
        
        float clip_left
        float clip_top
        float clip_width
        float clip_height
        
        float angle

    enum ShaderType:
        SHADER_FRAGMENT,
        SHADER_VERTEX,
        SHADER_GEOMETRY

    void vid_initialize (string name, int width, int height, int fullscreen,
        int fullwindow, int display, int x, int y) except +
    unsigned int vid_compileshader (string source, int type) except +
    unsigned int vid_compileprogram (unsigned int *shaders, unsigned int numshaders) except +
    void vid_shutdown ()
    int vid_loadtexture (string name, int width, int height,
        const unsigned char *data)
    void vid_unloadtexture (string name)
    void vid_cleartextures ()
    void vid_clearscreen ()
    void vid_draw2d (string graphic, float left, float top, float width,
        float height)
    void vid_swapbuffer ()

# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "video_cpp.hpp":
    enum ShaderType:
        SHADER_FRAGMENT,
        SHADER_VERTEX,
        SHADER_GEOMETRY

    int vid_initialize (char *name, int width, int height, int fullscreen,
        int fullwindow, int display, int x, int y) except 0
    unsigned int vid_compileshader (char *source, int type) except 0
    unsigned int vid_compileprogram (unsigned int *shaders,
        unsigned int numshaders) except 0
    void vid_use2dprogram (unsigned int program)
    void vid_use3dprogram (unsigned int program)
    void vid_shutdown (void)
    int vid_loadtexture (char *name, int width, int height,
        const unsigned char *data)
    void vid_unloadtexture (char *name)
    void vid_cleartextures (void)
    void vid_clearscreen (void)
    void vid_draw2d (char *graphic, float left, float top, float width,
        float height)
    void vid_swapbuffer (void)

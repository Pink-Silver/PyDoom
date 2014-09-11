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
        
    cdef cppclass CScreen:
        CScreen (string name, int width, int height, int fullscreen,
        int fullwindow, int display, int x, int y) except +
        
        void Shutdown ()
        
        # Texture binding
        int BindTexture (string name, int width, int height,
            const unsigned char *data)
        void DropTexture (string name)
        void ClearTextures ()
        
        # Drawing
        void DrawClear ()
        void DrawHUD (vector[CHUDElement *] elements)
        void DrawSwapBuffer ()

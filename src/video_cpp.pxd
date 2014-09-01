# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

from libcpp.string cimport string

cdef extern from "video_cpp.hpp":
    cdef cppclass CScreen:
        CScreen (string name, int width, int height, int fullscreen,
        int fullwindow, int display, int x, int y) except +
        
        void Shutdown ()
        int BindTexture (string name, int width, int height,
            const unsigned char *data)
        void DropTexture (string name)
        void ClearTextures ()

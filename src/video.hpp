// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

#ifndef __VIDEO_HPP__

bool InitVideo (void);
void QuitVideo (void);

PyObject * PyInit_PyDoom_Video (void);

struct PyVideoScreen: PyObject
{
public:
    SDL_Window *win;
    SDL_GLContext context;

    static PyObject *NewScreen (PyTypeObject *subtype, PyObject *args, PyObject *kwds);
    static void DestroyScreen (PyVideoScreen *screenptr);
};

#endif // __VIDEO_HPP__

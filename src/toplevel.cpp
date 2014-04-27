// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

// Python
#include <Python.h>

// SDL
#include "SDL.h"

// OpenGL
#ifdef WIN32
#include <Windows.h>
#endif
#include <gl/gl.h>

bool InitToplevel (void)
{
    int err = SDL_Init (SDL_INIT_TIMER | SDL_INIT_EVENTS | SDL_INIT_VIDEO);
    if (err)
        return false;
    
    return true;
}

void QuitToplevel (void)
{
    SDL_Quit ();
}

static PyMethodDef toplevel_methods[] = {
    {NULL, NULL, 0, NULL} // Sentinel
};

static struct PyModuleDef toplevel_module = {
    PyModuleDef_HEAD_INIT,
    "toplevel",
    "PyDoom's toplevel window handling",
    -1,
    toplevel_methods
};

PyMODINIT_FUNC PyInit_toplevel (void)
{
    PyObject *m;
    
    m = PyModule_Create (&toplevel_module);
    if (m == NULL)
        return NULL;
    
    return m;
}

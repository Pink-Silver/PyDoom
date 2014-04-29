// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

// Python
#define PY_SSIZE_T_CLEAN
#include <Python.h>

// SDL
#include "SDL.h"

// OpenGL
#ifdef WIN32
#include <Windows.h>
#endif
#include <gl/gl.h>

static SDL_Window *topwindow;
static SDL_GLContext *glcontext;

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

PyObject * toplevel_CreateWindow (PyObject *self, PyObject *args)
{
    int width, height;
    bool fullscreen;
    
    if (topwindow) // Return False if we already have a window
        Py_RETURN_FALSE;

    int ok = PyArg_ParseTuple(args, "(ii)p", &width, &height, &fullscreen);
    if (!ok)
        return NULL;
    
    int flags = SDL_WINDOW_OPENGL;
    if (fullscreen)
        flags |= SDL_WINDOW_FULLSCREEN;
    
    topwindow = SDL_CreateWindow (
        "PyDoom",
        SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED,
        width,
        height,
        flags
    );
    
    if (!topwindow) // Could not create a window for some reason
        Py_RETURN_FALSE;
    
    glcontext = new SDL_GLContext;
    *glcontext = SDL_GL_CreateContext (topwindow);
    if (!glcontext)
    {
        SDL_DestroyWindow (topwindow);
        topwindow = NULL;
        Py_RETURN_FALSE;
    }

    Py_RETURN_TRUE;
}

PyObject * toplevel_DestroyWindow (PyObject *self, PyObject *args)
{
    if (topwindow)
    {
        SDL_DestroyWindow (topwindow);
        topwindow = NULL;
        SDL_GL_DeleteContext (*glcontext);
        delete glcontext;
    }
    
    Py_RETURN_NONE;
}

PyObject * toplevel_HaveWindow (PyObject *self, PyObject *args)
{
    if (!topwindow)
        Py_RETURN_FALSE;
    
    Py_RETURN_TRUE;
}

static PyMethodDef toplevel_methods[] = {
    { "CreateWindow",  toplevel_CreateWindow,  METH_VARARGS,
    "Creates the top-level window. Returns True if a new window was created, False otherwise." },
    { "DestroyWindow", toplevel_DestroyWindow, METH_NOARGS,
    "Destroys the top-level window if there is one. No return." },
    { "HaveWindow",    toplevel_HaveWindow,    METH_NOARGS,
    "Returns True if there's a top-level window, False otherwise." },
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

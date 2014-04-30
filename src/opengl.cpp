// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

#include "global.hpp"

// SDL
#include "SDL.h"

// OpenGL
#ifdef WIN32
#include <Windows.h>
#endif
#include <gl/gl.h>

static SDL_Window *topwindow;
static SDL_GLContext *glcontext;
static int topwinwidth, topwinheight;

bool InitFramework (void)
{
    topwindow = NULL;
    glcontext = NULL;
    
    topwinwidth = topwinheight = 0;
    
    int err = SDL_Init (SDL_INIT_TIMER | SDL_INIT_EVENTS | SDL_INIT_VIDEO);
    if (err)
        return false;
    
    return true;
}

void QuitFramework (void)
{
    SDL_Quit ();
}

// WINDOW FUNCTIONS

PyObject * PyDoom_GL_CreateWindow (PyObject *self, PyObject *args)
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
    
    topwinwidth  = width;
    topwinheight = height;

    Py_RETURN_TRUE;
}

PyObject * PyDoom_GL_DestroyWindow (PyObject *self, PyObject *args)
{
    if (topwindow)
    {
        SDL_DestroyWindow (topwindow);
        topwindow = NULL;
        SDL_GL_DeleteContext (*glcontext);
        delete glcontext;
    }
    
    topwinwidth  = 0;
    topwinheight = 0;
    
    Py_RETURN_NONE;
}

PyObject * PyDoom_GL_HaveWindow (PyObject *self, PyObject *args)
{
    if (!topwindow)
        Py_RETURN_FALSE;
    
    Py_RETURN_TRUE;
}

// DRAWING FUNCTIONS

PyObject * PyDoom_GL_LoadTexture (PyObject *self, PyObject *args)
{
    PyObject *image;
    int ok = PyArg_ParseTuple (args, "O", &image);
    if (!ok)
        return NULL;
    
    PyObject *dimensions = PyObject_GetAttrString (image, "dimensions");
    
    if (!dimensions)
        PyErr_SetString (PyExc_TypeError, "Passed object does not have set dimensions");
    
    int width, height;
    if (!PyArg_ParseTuple (dimensions, "ii", &width, &height)) return NULL;
    
    PyObject *bufferobj = PyObject_CallMethod (image, "GetBuffer", NULL);
    if (!bufferobj)
        PyErr_SetString (PyExc_TypeError, "Failed to call object's GetBuffer method");
    
    Py_buffer buf;
    
    int err = PyObject_GetBuffer (bufferobj, &buf, PyBUF_SIMPLE);
    if (err)
    {
        PyErr_SetString (PyExc_ValueError, "Could not return a buffer");
        return NULL;
    }
    
    glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

    unsigned int gltex;
    glGenTextures (1, &gltex);
    glBindTexture (GL_TEXTURE_2D, gltex);
    
    glPixelStorei (GL_UNPACK_ALIGNMENT, 1);
    glTexImage2D (GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, buf.buf);
    glTexEnvf (GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    glTexParameterf (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

    glEnable (GL_TEXTURE_2D);
    glEnable (GL_BLEND);
    
    glOrtho (0.0f, 640.0f, 480.0, 0.0, 0.0, 1.0);
    
    glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glColor4f (1.0,1.0,1.0,1.0);
    
    glBindTexture (GL_TEXTURE_2D, gltex);
    glBegin (GL_QUADS);
    glTexCoord2f (0.0f,0.0f);
    glVertex2i (0,0);
    glTexCoord2f (0.0f,1.0f);
    glVertex2i (0,height);
    glTexCoord2f (1.0f,1.0f);
    glVertex2i (width,height);
    glTexCoord2f (1.0f,0.0f);
    glVertex2i (width,0);
    glEnd ();
    
    glDisable (GL_BLEND);
    glDisable (GL_TEXTURE_2D);
    
    PyBuffer_Release (&buf);

    Py_RETURN_NONE;
}

PyObject * PyDoom_GL_FinishDrawing (PyObject *self, PyObject *args)
{
    if (!topwindow)
        Py_RETURN_NONE;
    
    SDL_GL_SwapWindow (topwindow);
    
    Py_RETURN_NONE;
}

// MODULE DEFINITION

static PyMethodDef PyDoom_GL_Methods[] = {
    // Window handling
    { "CreateWindow",  PyDoom_GL_CreateWindow,  METH_VARARGS,
    "Creates the top-level window. Returns True if a new window was created, False otherwise." },
    { "DestroyWindow", PyDoom_GL_DestroyWindow, METH_NOARGS,
    "Destroys the top-level window if there is one." },
    { "HaveWindow",    PyDoom_GL_HaveWindow,    METH_NOARGS,
    "Returns True if there's a top-level window, False otherwise." },
    
    // OpenGL drawing
    { "LoadTexture",   PyDoom_GL_LoadTexture,   METH_VARARGS,
    "Test function." },
    { "FinishDrawing", PyDoom_GL_FinishDrawing, METH_NOARGS,
    "Finishes drawing the OpenGL context and updates the window." },
    
    {NULL, NULL, 0, NULL} // Sentinel
};

static PyModuleDef PyDoom_GL_Module = {
    PyModuleDef_HEAD_INIT,
    "PyDoom_OpenGL",
    "OpenGL rendering context and topmost window control",
    -1,
    PyDoom_GL_Methods
};

PyMODINIT_FUNC PyInit_PyDoom_GL (void)
{
    PyObject *m;
    
    m = PyModule_Create (&PyDoom_GL_Module);
    if (m == NULL)
        return NULL;
    
    return m;
}

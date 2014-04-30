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

    if (!PyArg_ParseTuple(args, "(ii)p", &width, &height, &fullscreen))
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
    if (!PyArg_ParseTuple (args, "O", &image))
        return NULL;
    
    PyObject *dimensions = PyObject_GetAttrString (image, "dimensions");
    
    if (!dimensions)
    {
        PyErr_SetString (PyExc_TypeError, "Passed object does not have set dimensions");
        return NULL;
    }
    
    int width, height;
    if (!PyArg_ParseTuple (dimensions, "ii", &width, &height)) return NULL;
    
    PyObject *bufferobj = PyObject_CallMethod (image, "GetBuffer", NULL);
    if (!bufferobj)
    {
        PyErr_SetString (PyExc_TypeError, "Failed to call object's GetBuffer method");
        return NULL;
    }
    
    Py_buffer buf;
    
    if (PyObject_GetBuffer (bufferobj, &buf, PyBUF_SIMPLE))
    {
        PyErr_SetString (PyExc_ValueError, "Could not retrieve a texture buffer");
        return NULL;
    }
    
    unsigned int gltex;
    glGenTextures (1, &gltex);
    glBindTexture (GL_TEXTURE_2D, gltex);
    
    glPixelStorei (GL_UNPACK_ALIGNMENT, 1);
    glTexImage2D (GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, buf.buf);
    glTexEnvi (GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    PyBuffer_Release (&buf);
    
    PyObject *ret = Py_BuildValue ("I", gltex);
    
    return ret;
}

PyObject * PyDoom_GL_UnloadTexture (PyObject *self, PyObject *args)
{
    unsigned int gltex;
    
    if (!PyArg_ParseTuple (args, "I", &gltex))
        return NULL;
    
    glDeleteTextures (1, &gltex);
    
    Py_RETURN_NONE;
}

PyObject * PyDoom_GL_Draw2D (PyObject *self, PyObject *args)
{
    unsigned int gltex;
    int left, top, width, height;
    
    if (!PyArg_ParseTuple (args, "I(iiii)", &gltex, &left, &top, &width, &height))
        return NULL;
    
    glEnable (GL_TEXTURE_2D);
    glEnable (GL_BLEND);
    glPushMatrix ();
    
    glOrtho (0.0f, float(topwinwidth), float(topwinheight), 0.0, 0.0, 1.0);
    
    glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glColor4f (1.0,1.0,1.0,1.0);
    
    glBindTexture (GL_TEXTURE_2D, gltex);
    glBegin (GL_QUADS);
    glTexCoord2f (0.0f,0.0f);
    glVertex2i (left,top);
    glTexCoord2f (0.0f,1.0f);
    glVertex2i (left,top + height);
    glTexCoord2f (1.0f,1.0f);
    glVertex2i (left + width,top + height);
    glTexCoord2f (1.0f,0.0f);
    glVertex2i (left + width,top);
    glEnd ();
    
    glPopMatrix ();
    glDisable (GL_BLEND);
    glDisable (GL_TEXTURE_2D);
    
    Py_RETURN_NONE;
}

PyObject * PyDoom_GL_BeginDrawing (PyObject *self, PyObject *args)
{
    if (!topwindow)
        Py_RETURN_NONE;
    
    glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    
    Py_RETURN_NONE;
}

PyObject * PyDoom_GL_FinishDrawing (PyObject *self, PyObject *args)
{
    if (!topwindow)
        Py_RETURN_NONE;
    
    SDL_GL_SwapWindow (topwindow);
    SDL_PumpEvents ();
    
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
    "Saves a texture into OpenGL's video memory. Returns the texture ID." },
    { "UnloadTexture", PyDoom_GL_UnloadTexture, METH_VARARGS,
    "Deletes a texture that was previously saved into video memory." },
    { "Draw2D",        PyDoom_GL_Draw2D,        METH_VARARGS,
    "Given a texture ID and positional coordinates, draws a single graphic." },
    
    { "BeginDrawing",  PyDoom_GL_BeginDrawing,  METH_NOARGS,
    "Clears the GL buffers and prepares to begin drawing." },
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

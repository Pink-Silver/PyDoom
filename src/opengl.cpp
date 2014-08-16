// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

#include "global.hpp"

// Math
#include <cmath>

// SDL
#include "SDL.h"

// OpenGL
#ifdef WIN32
//#pragma warning( disable : 4507 34 )
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
    
    PyObject *texprop = Py_BuildValue ("I", gltex);
    PyObject_SetAttrString (image, "gltexture", texprop);
    
    Py_RETURN_NONE;
}

PyObject * PyDoom_GL_UnloadTexture (PyObject *self, PyObject *args)
{
    PyObject *image;
    
    if (!PyArg_ParseTuple (args, "O", &image))
        return NULL;
    
    if (!PyObject_HasAttrString (image, "gltexture"))
        Py_RETURN_NONE;
    
    PyObject *glprop = PyObject_GetAttrString (image, "gltexture");
    
    unsigned int gltex = PyLong_AsUnsignedLong (glprop);
    if (PyErr_Occurred ()) return NULL;
    
    glDeleteTextures (1, &gltex);
    
    Py_RETURN_NONE;
}

PyObject * PyDoom_GL_Draw2D (PyObject *self, PyObject *args)
{
    PyObject *image;
    unsigned int gltex = 0;
    float left, top, width, height;
    float clip_l, clip_t, clip_w, clip_h;
    float angle;
    
    if (!PyArg_ParseTuple (args, "O(ffff)|(ffff)f", &image,
        &left, &top, &width, &height,
        &clip_l, &clip_t, &clip_w, &clip_h,
        &angle
        ))
        return NULL;
    
    if (!PyObject_HasAttrString (image, "dimensions"))
    {
        PyErr_SetString (PyExc_TypeError, "Passed object is missing image dimensions");
        return NULL;
    }
    
    PyObject *dimensions = PyObject_GetAttrString (image, "dimensions");
    float texwidth, texheight;
    if (!PyArg_ParseTuple (dimensions, "ff", &texwidth, &texheight)) return NULL;
    
    if (!PyObject_HasAttrString (image, "gltexture"))
        PyDoom_GL_LoadTexture (self, Py_BuildValue ("(O)", image));
    
    PyObject *glprop = PyObject_GetAttrString (image, "gltexture");

    gltex = PyLong_AsUnsignedLong (glprop);
    if (PyErr_Occurred ()) return NULL;
    
    if (!width)
        width = texwidth;
    if (!height)
        height = texheight;
    
    if (clip_w <= 0)
        clip_w = 1.0;
    if (clip_h <= 0)
        clip_h = 1.0;
    
    float tl_x, tl_y, tr_x, tr_y;
    float bl_x, bl_y, br_x, br_y;
    
    tl_x = -(float(width)/2); tl_y = -(float(height)/2);
    tr_x =  (float(width)/2); tr_y = -(float(height)/2);
    bl_x = -(float(width)/2); bl_y =  (float(height)/2);
    br_x =  (float(width)/2); br_y =  (float(height)/2);
    
    glEnable (GL_TEXTURE_2D);
    glEnable (GL_BLEND);
    
    glPushMatrix ();
    glOrtho (0.0f, float(topwinwidth), float(topwinheight), 0.0, -1.0, 1.0);
    glTranslatef (left+(float(width)/2), top+(float(height)/2), 0);
    glRotatef (angle, 0, 0, 1);
    
    glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glColor4f (1.0,1.0,1.0,1.0);
    
    glBindTexture (GL_TEXTURE_2D, gltex);
    glBegin (GL_QUADS);
    glTexCoord2f (clip_l / texwidth, clip_t / texheight);
    glVertex2f (tl_x,tl_y);
    glTexCoord2f ((clip_l + clip_w) / texwidth, clip_t / texheight);
    glVertex2f (tr_x,tr_y);
    glTexCoord2f ((clip_l + clip_w) / texwidth, (clip_t + clip_h) / texheight);
    glVertex2f (br_x,br_y);
    glTexCoord2f (clip_l / texwidth, (clip_t + clip_h) / texheight);
    glVertex2f (bl_x,bl_y);
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
    "pydoom.opengl",
    "OpenGL rendering context and topmost window control",
    -1,
    PyDoom_GL_Methods
};

PyObject * PyInit_PyDoom_GL (void)
{
    PyObject *m;
    
    m = PyModule_Create (&PyDoom_GL_Module);
    if (m == NULL)
        return NULL;
    
    return m;
}

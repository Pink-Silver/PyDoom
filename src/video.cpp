// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

#include "global.hpp"
#include "video.hpp"

bool InitVideo (void)
{
    int err = SDL_Init (SDL_INIT_TIMER | SDL_INIT_EVENTS | SDL_INIT_VIDEO);
    if (err)
        return false;
    
    return true;
}

void QuitVideo (void)
{
    SDL_Quit ();
}

////// Class: Screen (PyVideoScreen) //////

static PyTypeObject PyVideoScreenType = {
    PyVarObject_HEAD_INIT(NULL, 0)
    "pydoom_video.Screen",
    sizeof (PyVideoScreen),
};

PyObject *PyVideoScreen::NewScreen (PyTypeObject *subtype, PyObject *args,
    PyObject *kwds)
{
    PyVideoScreen *screenptr;
    const char *wintitle;
    int width, height, x, y;
    int fullscreen, fullwindow;

    if (!PyArg_ParseTuple (args, "siiiipp", &wintitle, &x, &y, &width, &height,
        &fullscreen, &fullwindow))
        return NULL;

    unsigned int flags = SDL_WINDOW_OPENGL;

    if (x < 0)
        x = SDL_WINDOWPOS_CENTERED;
    if (y < 0)
        y = SDL_WINDOWPOS_CENTERED;

    if (fullwindow)
        flags |= SDL_WINDOW_FULLSCREEN_DESKTOP;
    else if (fullscreen)
        flags |= SDL_WINDOW_FULLSCREEN;
    
    screenptr = new PyVideoScreen();
    PyObject_Init (screenptr, &PyVideoScreenType);

    screenptr->win = SDL_CreateWindow (wintitle, x, y, width, height, flags);
    if (!screenptr->win)
    {
        delete screenptr;
        PyErr_SetString (PyExc_RuntimeError, "Could not create screen/window");
        return NULL;
    }

    screenptr->context = SDL_GL_CreateContext (screenptr->win);
    if (!screenptr->context)
    {
        SDL_DestroyWindow (screenptr->win);
        delete screenptr;
        PyErr_SetString (PyExc_RuntimeError, "Could not create OpenGL context");
        return NULL;
    }
    
    return screenptr;
}

void PyVideoScreen::DestroyScreen (PyVideoScreen *screenptr)
{
    SDL_GL_DeleteContext (screenptr->context);
    SDL_DestroyWindow (screenptr->win);

    delete screenptr;
}

// MODULE DEFINITION

static PyMethodDef PyDoom_Video_Methods[] = {
    {NULL, NULL, 0, NULL} // Sentinel
};

static PyModuleDef PyDoom_Video_Module = {
    PyModuleDef_HEAD_INIT,
    "pydoom_video",
    "Provides low-level video controls for rendering.",
    -1,
    NULL
};

PyObject * PyInit_PyDoom_Video (void)
{
    PyVideoScreenType.tp_doc = "A screen with an attached OpenGL context.";
    PyVideoScreenType.tp_flags = Py_TPFLAGS_DEFAULT;
    PyVideoScreenType.tp_dealloc = (destructor)PyVideoScreen::DestroyScreen;
    PyVideoScreenType.tp_new = PyVideoScreen::NewScreen;
    
    if (PyType_Ready(&PyVideoScreenType) < 0)
        return NULL;

    PyObject *m;
    
    m = PyModule_Create (&PyDoom_Video_Module);
    if (m == NULL)
        return NULL;

    Py_INCREF(&PyVideoScreenType);
    PyModule_AddObject(m, "Screen", (PyObject *)&PyVideoScreenType);
    
    return m;
}

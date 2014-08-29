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
    
    SDL_DisableScreenSaver ();
    
    return true;
}

void QuitVideo (void)
{
    SDL_Quit ();
}

////// Class: Screen //////

PyTypeObject PyDoom_Screen::Type = {
    PyVarObject_HEAD_INIT(NULL, 0)
    "pydoom_video.Screen",
    sizeof (PyDoom_Screen),
};

PyMethodDef PyDoom_Screen::Methods[] = {
    {"bindTexture", (PyCFunction)PyDoom_Screen::python_bindTexture, METH_VARARGS,
        PyDoc_STR("Binds a graphic name to the OpenGL context.")},
    {"shutdown", (PyCFunction)PyDoom_Screen::python_shutdown, METH_NOARGS,
        PyDoc_STR("Closes the OpenGL window and releases the context.")},
    {NULL,	NULL},
};

PyObject *PyDoom_Screen::NewScreen (PyTypeObject *subtype, PyObject *args,
    PyObject *kwds)
{
    PyDoom_Screen *screenptr;
    const char *wintitle;
    int width, height, x, y;
    int fullscreen, fullwindow;

    x = y = -1;

    if (!PyArg_ParseTuple (args, "siipp|ii", &wintitle, &width, &height,
        &fullscreen, &fullwindow, &x, &y))
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
    
    screenptr = new PyDoom_Screen();
    PyObject_Init (screenptr, &PyDoom_Screen::Type);

    SDL_GL_SetAttribute (SDL_GL_RED_SIZE, 8);
    SDL_GL_SetAttribute (SDL_GL_GREEN_SIZE, 8);
    SDL_GL_SetAttribute (SDL_GL_BLUE_SIZE, 8);
    SDL_GL_SetAttribute (SDL_GL_ALPHA_SIZE, 8);
    SDL_GL_SetAttribute (SDL_GL_MULTISAMPLEBUFFERS, 1);
    SDL_GL_SetAttribute (SDL_GL_MULTISAMPLESAMPLES, 2);
    SDL_GL_SetAttribute (SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute (SDL_GL_CONTEXT_MINOR_VERSION, 3);
    SDL_GL_SetAttribute (SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
    
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

    SDL_GL_MakeCurrent (screenptr->win, screenptr->context);

    screenptr->glGenerateMipmap_ptr = (GL_GenerateMipmap_Func) SDL_GL_GetProcAddress ("glGenerateMipmap");

    return screenptr;
}

void PyDoom_Screen::Shutdown ()
{
    if (!this->win)
        return;

    SDL_GL_DeleteContext (this->context);
    SDL_DestroyWindow (this->win);

    this->context = NULL;
    this->win = NULL;

    if (this->textures)
    {
        free (this->textures);
        this->textures = NULL;
        this->numtextures = 0;
    }
}

void PyDoom_Screen::DestroyScreen (PyDoom_Screen *screenptr)
{
    screenptr->Shutdown ();
    delete screenptr;
}

PyObject *PyDoom_Screen::python_shutdown (PyDoom_Screen *self)
{
    self->Shutdown ();

    Py_RETURN_NONE;
};

PyObject *PyDoom_Screen::python_bindTexture (PyDoom_Screen *self, PyObject *args)
{
    // Borrowed
    PyObject *nameobj = NULL;
    PyObject *imageobj = NULL;

    // New
    PyObject *widthobj = NULL;
    PyObject *heightobj = NULL;
    PyObject *dataobj = NULL;
    PyObject *lowername = NULL;

    const char *name;
    Py_buffer buffer;
    size_t width, height;

    if (!PyArg_ParseTuple (args, "O!O", &PyUnicode_Type, &nameobj, &imageobj))
        return NULL;

    if (!PyObject_HasAttrString (imageobj, "width"))
    {
        PyErr_SetString (PyExc_AttributeError, "image object requires a width");
        goto exception_cleanup;
    }

    if (!PyObject_HasAttrString (imageobj, "height"))
    {
        PyErr_SetString (PyExc_AttributeError, "image object requires a height");
        goto exception_cleanup;
    }

    if (!PyObject_HasAttrString (imageobj, "data"))
    {
        PyErr_SetString (PyExc_AttributeError, "image object requires a data buffer");
        goto exception_cleanup;
    }

    widthobj  = PyObject_GetAttrString (imageobj, "width");
    heightobj = PyObject_GetAttrString (imageobj, "height");
    dataobj   = PyObject_GetAttrString (imageobj, "data");

    if (!widthobj)
        goto exception_cleanup;
    if (!heightobj)
        goto exception_cleanup;
    if (!dataobj)
        goto exception_cleanup;

    if (!PyLong_Check (widthobj))
    {
        PyErr_SetString (PyExc_AttributeError, "image width is not of type 'int'");
        goto exception_cleanup;
    }

    if (!PyLong_Check (heightobj))
    {
        PyErr_SetString (PyExc_AttributeError, "image height is not of type 'int'");
        goto exception_cleanup;
    }

    if (!PyObject_CheckBuffer (dataobj))
    {
        PyErr_SetString (PyExc_AttributeError, "image data does not support buffer protocol");
        goto exception_cleanup;
    }

    lowername = PyObject_CallMethod (nameobj, "lower", NULL);
    if (!lowername)
        goto exception_cleanup;

    name = PyUnicode_AsUTF8 (lowername);
    if (!name)
        goto exception_cleanup;

    width = PyLong_AsSize_t (widthobj);
    if (PyErr_Occurred ())
        goto exception_cleanup;

    height = PyLong_AsSize_t (heightobj);
    if (PyErr_Occurred ())
        goto exception_cleanup;

    int result = PyObject_GetBuffer (dataobj, &buffer, PyBUF_SIMPLE);
    if (result)
        goto exception_cleanup;

    try
    {
        self->bindTexture (name, width, height, buffer);
    }
    catch (PyDoom_MemoryError)
    {
        PyErr_SetString (PyExc_MemoryError, "Ran out of memory attempting to bind texture");
        goto exception_cleanup;
    }

    Py_RETURN_NONE;

exception_cleanup:
    Py_XDECREF (widthobj);
    Py_XDECREF (heightobj);
    Py_XDECREF (dataobj);
    Py_XDECREF (lowername);
    return NULL;
}

void PyDoom_Screen::bindTexture (const char *name, int width, int height, Py_buffer data)
{
    // Image data should be provided to us as RGBA8.

    GLuint lastTexture = 0;
    glGetIntegerv (GL_TEXTURE_BINDING_2D, (GLint*) &lastTexture);

    GLuint newtex;
    size_t index;

    index = this->numtextures++;

    PyDoom_GLTextureMapping *tmp = (PyDoom_GLTextureMapping *) calloc (this->numtextures,
        sizeof (PyDoom_GLTextureMapping));

    if (!tmp)
    {
        --this->numtextures;
        throw PyDoom_MemoryError();
    }

    this->textures = tmp;

    glGenTextures (1, &newtex);
    glBindTexture (GL_TEXTURE_2D, newtex);

    this->textures[index].texturename = name;
    this->textures[index].texturenum = newtex;

    glPixelStorei (GL_UNPACK_ALIGNMENT, 1);
    glTexImage2D (GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data.buf);
    glTexEnvi (GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

    this->glGenerateMipmap_ptr (GL_TEXTURE_2D);
    glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);

    PyBuffer_Release (&data);
    glBindTexture (GL_TEXTURE_2D, lastTexture);
}

void PyDoom_Screen::dropTextures (size_t numnames, char **names)
{
    size_t oldcount = this->numtextures;

    for (size_t i = 0; i < numnames; ++i)
    {
        const char *thisname = names[i];

        bool found = false;
        int foundindex = 0;
        for (size_t j = 0; j < this->numtextures; ++j)
        {
            if (!strcmp (thisname, this->textures[j].texturename))
            {
                found = true;
                foundindex = j;
                break;
            }
        }

        if (found)
        {
            glDeleteTextures (1, &this->textures[foundindex].texturenum);

            this->textures[foundindex] = this->textures[this->numtextures - 1];
            --this->numtextures;
        }
    }

    if (this->numtextures < oldcount)
    {
        this->textures = (PyDoom_GLTextureMapping *) realloc (this->textures,
            sizeof (PyDoom_GLTextureMapping) * this->numtextures);
    }
}

void PyDoom_Screen::clearTextures ()
{
    SDL_GL_MakeCurrent (this->win, this->context);

    GLuint *texarray = (GLuint *) calloc (this->numtextures, sizeof (GLuint));

    for (size_t i = 0; i < this->numtextures; ++i)
        texarray[i] = this->textures[i].texturenum;

    glDeleteTextures (this->numtextures, texarray);

    free (this->textures);
    this->textures = NULL;
    this->numtextures = 0;
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
    PyDoom_Screen::Type.tp_doc = "A screen with an attached OpenGL context.";
    PyDoom_Screen::Type.tp_flags = Py_TPFLAGS_DEFAULT;
    PyDoom_Screen::Type.tp_dealloc = (destructor)PyDoom_Screen::DestroyScreen;
    PyDoom_Screen::Type.tp_new = PyDoom_Screen::NewScreen;
    PyDoom_Screen::Type.tp_methods = PyDoom_Screen::Methods;
    
    if (PyType_Ready(&PyDoom_Screen::Type) < 0)
        return NULL;

    PyObject *m;
    
    m = PyModule_Create (&PyDoom_Video_Module);
    if (m == NULL)
        return NULL;

    Py_INCREF(&PyDoom_Screen::Type);
    PyModule_AddObject(m, "Screen", (PyObject *)&PyDoom_Screen::Type);
    
    return m;
}

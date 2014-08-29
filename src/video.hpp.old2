// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

#ifndef VIDEO_HPP
#define VIDEO_HPP

// GL API stuff
typedef void (APIENTRY * GL_GenerateMipmap_Func)(unsigned int);

bool InitVideo (void);
void QuitVideo (void);

PyObject * PyInit_PyDoom_Video (void);

struct PyDoom_GLTextureMapping
{
    GLuint texturenum;
    const char *texturename;
};

class PyDoom_Screen: PyObject
{
public:
    SDL_Window *win;
    SDL_GLContext context;

    // GL API stuff
    GL_GenerateMipmap_Func glGenerateMipmap_ptr;

    // Python Object
    static PyTypeObject Type;
    static PyMethodDef Methods[];

    static PyObject *NewScreen (PyTypeObject *subtype, PyObject *args, PyObject *kwds);
    static void DestroyScreen (PyDoom_Screen *screenptr);
    void Shutdown ();

    // GL Textures
    PyDoom_GLTextureMapping *textures;
    size_t numtextures;

    void bindTexture (const char *name, int width, int height, Py_buffer data);
    void dropTextures (size_t numnames, char **names);
    void clearTextures ();

    static PyObject *python_shutdown (PyDoom_Screen *self);
    static PyObject *python_bindTexture (PyDoom_Screen *self, PyObject *args);
    static PyObject *python_dropTextures (PyDoom_Screen *self, PyObject *args);
};

#endif // VIDEO_HPP

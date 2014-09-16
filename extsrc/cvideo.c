// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

#ifdef _MSC_VER
    #pragma warning(disable: 4996) // blah blah "sprintf is unsafe USE OUR WINDOWS-SPECIFIC FUNCTIONS INSTEAD"
#endif

// Python
//#define PY_SSIZE_T_CLEAN
//#include <Python.h>

// SDL & OpenGL
#include <SDL.h>
#include <GL/glew.h>

#include "cvideo.h"

SDL_Window *window;
SDL_GLContext context;

GLuint drawing_program;

int vid_initialize (char *name, int width, int height, int fullscreen,
    int fullwindow, int display, int x, int y)
{
    int flags;
    GLenum glewstatus;
    
    SDL_Init (SDL_INIT_VIDEO | SDL_INIT_EVENTS | SDL_INIT_TIMER);
    
    SDL_GL_SetAttribute (SDL_GL_RED_SIZE, 8);
    SDL_GL_SetAttribute (SDL_GL_GREEN_SIZE, 8);
    SDL_GL_SetAttribute (SDL_GL_BLUE_SIZE, 8);
    SDL_GL_SetAttribute (SDL_GL_ALPHA_SIZE, 8);
    SDL_GL_SetAttribute (SDL_GL_MULTISAMPLEBUFFERS, 1);
    SDL_GL_SetAttribute (SDL_GL_MULTISAMPLESAMPLES, 4);
    SDL_GL_SetAttribute (SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute (SDL_GL_CONTEXT_MINOR_VERSION, 3);
    SDL_GL_SetAttribute (SDL_GL_CONTEXT_PROFILE_MASK,
        SDL_GL_CONTEXT_PROFILE_CORE);
    
    flags = SDL_WINDOW_OPENGL;
    
    if (x < 0)
        x = SDL_WINDOWPOS_CENTERED_DISPLAY (display);
    if (y < 0)
        y = SDL_WINDOWPOS_CENTERED_DISPLAY (display);
    
    if (fullscreen)
        flags |= SDL_WINDOW_FULLSCREEN;
    
    if (fullwindow)
    {
        flags &= ~SDL_WINDOW_FULLSCREEN;
        flags |= SDL_WINDOW_FULLSCREEN_DESKTOP;
    }
    
    window = SDL_CreateWindow (name, x, y, width, height, flags);
    
    if (!window)
    {
        const char *err = SDL_GetError ();
        SDL_ClearError ();
        return 0;
        //throw std::runtime_error (err);
    }
    
    context = SDL_GL_CreateContext (window);
    
    if (!context)
    {
        const char *err = SDL_GetError ();
        SDL_ClearError ();
        return 0;
        //throw std::runtime_error (err);
    }
    
    glewstatus = glewInit ();
    
    if (glewstatus != GLEW_OK)
        return 0;
        //throw std::runtime_error ((const char *) glewGetErrorString(glewstatus));
    
    if (!GLEW_VERSION_3_3)
        return 0;
        //throw std::runtime_error ("OpenGL 3.3 is not supported");

    // Clear to black
    glClearColor (0.0f, 0.0f, 0.0f, 0.0f);
    
    return 1;
}

unsigned int vid_compileshader (const char *source, int type)
{
    GLuint shader = 0;
    GLenum gentype = 0;
    GLint status = GL_FALSE;
    
    switch (type)
    {
    case SHADER_FRAGMENT:
        gentype = GL_FRAGMENT_SHADER;
        break;
    case SHADER_VERTEX:
        gentype = GL_VERTEX_SHADER;
        break;
    case SHADER_GEOMETRY:
        gentype = GL_GEOMETRY_SHADER;
        break;
    default:
        return 0;
    }
    
    shader = glCreateShader (gentype);
    
    glShaderSource (shader, 1, (const GLchar **) source, NULL);
    glGetShaderiv (shader, GL_COMPILE_STATUS, &status);
    
    if (status != GL_TRUE)
    {
        glDeleteShader (shader);
        return 0;
    }
    
    return shader;
}

unsigned int vid_compileprogram (unsigned int *shaders, unsigned int numshaders)
{
    GLuint program;
    GLint status;
    unsigned int i;
    
    program = glCreateProgram ();
    status = GL_FALSE;
    
    for (i = 0; i < numshaders; ++i)
    {
        glAttachShader (program, shaders[i]);
    }
    
    glLinkProgram (program);
    glGetProgramiv (program, GL_LINK_STATUS, &status);
    
    if (status != GL_TRUE)
    {
        glDeleteProgram (program);
        return 0;
    }
    
    return program;
}

void vid_useprogram (unsigned int program)
{
    drawing_program = program;
}

void vid_shutdown (void)
{
    if (window == NULL) return;
    
    SDL_GL_DeleteContext (context);
    SDL_DestroyWindow (window);
    context = NULL;
    window = NULL;
    
    SDL_Quit ();
}

unsigned int vid_loadtexture (int width, int height, const unsigned char *data)
{
    GLuint newtex;
    GLuint lastTexture = 0;

    // Image data is assumed provided to us as RGBA8.

    glGetIntegerv (GL_TEXTURE_BINDING_2D, (GLint*) &lastTexture);

    glGenTextures (1, &newtex);
    glBindTexture (GL_TEXTURE_2D, newtex);
    glTexStorage2D (GL_TEXTURE_2D, 8, GL_RGBA8, width, height);

    glPixelStorei (GL_UNPACK_ALIGNMENT, 1);
    glTexSubImage2D (GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGBA,
        GL_UNSIGNED_BYTE, data);
    glGenerateMipmap (GL_TEXTURE_2D);
    glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
        GL_NEAREST_MIPMAP_NEAREST);
    
    if (GL_EXT_texture_filter_anisotropic)
    {
        GLfloat animax;
        glGetFloatv (GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &animax);
        glTexParameterf (GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, animax);
    }
    
    glBindTexture (GL_TEXTURE_2D, lastTexture);

    return newtex;
}

void vid_unloadtexture (unsigned int tex)
{
    glDeleteTextures (1, &tex);
}

void vid_clearscreen (void)
{
    glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
}

void vid_draw2d (unsigned int tex, float left, float top, float width,
    float height)
{
    glBindTexture (GL_TEXTURE_2D, tex);
}

void vid_swapbuffer (void)
{
    SDL_GL_SwapWindow (window);
}

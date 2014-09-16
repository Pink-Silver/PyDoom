// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

#include "global.hpp"
#include "video_cpp.hpp"

SDL_Window *window;
SDL_GLContext context;

std::map<std::string, GLuint> textures;

GLuint program_2d_draw;
GLuint program_3d_draw;

void vid_initialize (std::string name, int width, int height, int fullscreen,
    int fullwindow, int display, int x, int y)
{
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
    
    int flags = SDL_WINDOW_OPENGL;
    
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
    
    window = SDL_CreateWindow (name.c_str (), x, y, width, height, flags);
    
    if (!window)
    {
        const char *err = SDL_GetError ();
        SDL_ClearError ();
        throw std::runtime_error (err);
    }
    
    context = SDL_GL_CreateContext (window);
    
    if (!context)
    {
        const char *err = SDL_GetError ();
        SDL_ClearError ();
        throw std::runtime_error (err);
    }
    
    GLenum glewstatus = glewInit ();
    
    if (glewstatus != GLEW_OK)
        throw std::runtime_error ((const char *) glewGetErrorString(glewstatus));
    
    if (!GLEW_VERSION_3_3)
        throw std::runtime_error ("OpenGL 3.3 is not supported");

    // Clear to black
    glClearColor (0.0f, 0.0f, 0.0f, 0.0f);
}

unsigned int vid_compileshader (std::string source, int type)
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
        throw std::runtime_error ("vid_compileshader received an invalid type");
    }
    
    shader = glCreateShader (gentype);
    
    glShaderSource (shader, 1, (const GLchar **) source.c_str (), NULL);
    glGetShaderiv (shader, GL_COMPILE_STATUS, &status);
    
    if (status != GL_TRUE)
    {
        glDeleteShader (shader);
        throw std::runtime_error ("vid_compileshader: the shader did not compile");
    }
    
    return shader;
}

unsigned int vid_compileprogram (unsigned int *shaders, unsigned int numshaders)
{
    GLuint program = glCreateProgram ();
    GLint status = GL_FALSE;
    
    for (unsigned int i = 0; i < numshaders; ++i)
        glAttachShader (program, shaders[i]);
    
    glLinkProgram (program);
    glGetProgramiv (program, GL_LINK_STATUS, &status);
    
    if (status != GL_TRUE)
    {
        glDeleteProgram (program);
        throw std::runtime_error ("vid_compileprogram: the program did not compile");
    }
    
    return program;
}

void vid_use2dprogram (unsigned int program)
{
    program_2d_draw = program;
}

void vid_use3dprogram (unsigned int program)
{
    program_3d_draw = program;
}

void vid_shutdown ()
{
    if (window == NULL) return;
    
    SDL_GL_DeleteContext (context);
    SDL_DestroyWindow (window);
    context = NULL;
    window = NULL;
    
    SDL_Quit ();
}

int vid_loadtexture (std::string name, int width, int height,
    const unsigned char *data)
{
    // Image data is assumed provided to us as RGBA8.

    if (textures.count (name) > 0)
        return 2;

    GLuint lastTexture = 0;
    glGetIntegerv (GL_TEXTURE_BINDING_2D, (GLint*) &lastTexture);

    GLuint newtex;

    glGenTextures (1, &newtex);
    glBindTexture (GL_TEXTURE_2D, newtex);
    glTexStorage2D (GL_TEXTURE_2D, 8, GL_RGBA8, width, height);

    glPixelStorei (GL_UNPACK_ALIGNMENT, 1);
    glTexSubImage2D (GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
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
    
    textures[name] = newtex;

    glBindTexture (GL_TEXTURE_2D, lastTexture);

    return 0;
}

void vid_unloadtexture (std::string name)
{
    if (!textures.count (name)) return;

    glDeleteTextures (1, &textures[name]);
    textures.erase (name);
}

void vid_cleartextures ()
{
    for (auto iter = textures.begin (); iter != textures.end (); ++iter)
    {
        glDeleteTextures (1, &iter->second);
    }
    textures.clear ();
}

void vid_clearscreen ()
{
    glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
}

void vid_draw2d (std::string graphic, float left, float top, float width, float height)
{
/*
    if (!elements.size ())
        return;

    std::vector<GLfloat> vertexes;

    glEnable (GL_TEXTURE_2D);
    glEnable (GL_BLEND);

    for (auto f = elements.begin (); f != elements.end (); ++f)
    {
        glPushMatrix ();
        glOrtho (0.0, 1.0, 1.0, 0.0, -1.0, 1.0);
        glTranslatef ((*f)->left + ((*f)->width / 2.0f), (*f)->top + ((*f)->height / 2), 0);
        glRotatef ((*f)->angle, 0, 0, 1);
    
        glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glColor4f (1.0, 1.0, 1.0, 1.0);
    
        glBindTexture (GL_TEXTURE_2D, this->textures[(*f)->graphic]);

        glBegin (GL_TRIANGLE_STRIP);
        glTexCoord2f ((*f)->clip_left, (*f)->clip_top);
        glVertex2f ((*f)->left, (*f)->top);
        glTexCoord2f ((*f)->clip_left, (*f)->clip_top + (*f)->clip_height);
        glVertex2f ((*f)->left, (*f)->top + (*f)->height);
        glTexCoord2f ((*f)->clip_left + (*f)->clip_width, (*f)->clip_top);
        glVertex2f ((*f)->left + (*f)->width, (*f)->top);
        glTexCoord2f ((*f)->clip_left + (*f)->clip_width, (*f)->clip_top + (*f)->clip_height);
        glVertex2f ((*f)->left + (*f)->width, (*f)->top + (*f)->height);
        glEnd ();

        glPopMatrix ();
    }

    glDisable (GL_TEXTURE_2D);
    glDisable (GL_BLEND);
*/
}

void vid_swapbuffer ()
{
    SDL_GL_SwapWindow (window);
}

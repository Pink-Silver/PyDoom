// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

#include "global.hpp"
#include "video_cpp.hpp"

CScreen::CScreen (std::string name, int width, int height, int fullscreen,
    int fullwindow, int display, int x, int y)
{
    SDL_GL_SetAttribute (SDL_GL_RED_SIZE, 8);
    SDL_GL_SetAttribute (SDL_GL_GREEN_SIZE, 8);
    SDL_GL_SetAttribute (SDL_GL_BLUE_SIZE, 8);
    SDL_GL_SetAttribute (SDL_GL_ALPHA_SIZE, 8);
    SDL_GL_SetAttribute (SDL_GL_MULTISAMPLEBUFFERS, 1);
    SDL_GL_SetAttribute (SDL_GL_MULTISAMPLESAMPLES, 2);
    SDL_GL_SetAttribute (SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute (SDL_GL_CONTEXT_MINOR_VERSION, 3);
    SDL_GL_SetAttribute (SDL_GL_CONTEXT_PROFILE_MASK,
        SDL_GL_CONTEXT_PROFILE_COMPATIBILITY);
    
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
}

CScreen::~CScreen ()
{
    Shutdown ();
}

void CScreen::Shutdown ()
{
    if (window == NULL) return;
    
    SDL_GL_DeleteContext (context);
    SDL_DestroyWindow (window);
    context = NULL;
    window = NULL;
}

int CScreen::BindTexture (std::string name, int width, int height,
    const unsigned char *data)
{
    // Image data is assumed provided to us as RGBA8.

    SDL_GL_MakeCurrent (window, context);

    if (textures.count (name) > 0)
        return 2;

    GLuint lastTexture = 0;
    glGetIntegerv (GL_TEXTURE_BINDING_2D, (GLint*) &lastTexture);

    GLuint newtex;

    glGenTextures (1, &newtex);
    glBindTexture (GL_TEXTURE_2D, newtex);

    glPixelStorei (GL_UNPACK_ALIGNMENT, 1);
    glTexImage2D (GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_RGBA,
        GL_UNSIGNED_BYTE, data);
    glTexEnvi (GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

    glGenerateMipmap (GL_TEXTURE_2D);
    glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
        GL_LINEAR_MIPMAP_LINEAR);
    
    textures[name] = newtex;

    glBindTexture (GL_TEXTURE_2D, lastTexture);

    return 0;
}

void CScreen::DropTexture (std::string name)
{
    if (!textures.count (name)) return;

    SDL_GL_MakeCurrent (window, context);
    glDeleteTextures (1, &textures[name]);
    textures.erase (name);
}

void CScreen::ClearTextures ()
{
    SDL_GL_MakeCurrent (window, context);
    for (auto iter = textures.begin (); iter != textures.end (); ++iter)
    {
        glDeleteTextures (1, &iter->second);
    }
    textures.clear ();
}

void CScreen::DrawClear ()
{
    SDL_GL_MakeCurrent (window, context);
    glClearColor (0.0f, 0.0f, 0.0f, 0.0f);
    glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
}

void CScreen::DrawHUD (std::vector<CHUDElement *> elements)
{
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
}

void CScreen::DrawSwapBuffer ()
{
    SDL_GL_SwapWindow (window);
}

// 2D HUD structures



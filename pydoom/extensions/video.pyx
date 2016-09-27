# Copyright (c) 2014, Kate Fox
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free

cdef extern from "defines.h":
    pass

cdef extern from "<GL/glcorearb.h>":
    ctypedef unsigned int GLenum
    ctypedef unsigned int GLuint
    ctypedef int GLint
    ctypedef int GLsizei
    ctypedef char GLchar
    
    enum:
        GL_TRUE
        GL_FALSE
        
        GL_FRAGMENT_SHADER
        GL_VERTEX_SHADER
        
        GL_COMPILE_STATUS
        GL_LINK_STATUS
        GL_INFO_LOG_LENGTH
        
        GL_COLOR_BUFFER_BIT
        GL_DEPTH_BUFFER_BIT
        GL_STENCIL_BUFFER_BIT
        
    void glClearColor (float red, float green, float blue, float alpha)
    void glClear (int mask)
    
    GLuint glCreateShader (GLenum type)
    void glShaderSource (GLuint shader, GLsizei count, const GLchar **string, const GLint *length)
    void glGetShaderiv (GLuint shader, GLenum pname, GLint *params)
    void glDeleteShader (GLuint shader)
    
    GLuint glCreateProgram ()
    void glAttachShader (GLuint program, GLuint shader)
    void glDetachShader (GLuint program, GLuint shader)
    void glLinkProgram (GLuint program)
    void glGetProgramiv (GLuint program, GLenum pname, GLint *params)
    void glDeleteProgram (GLuint program)
    
cdef extern from "<SDL.h>":
    ctypedef struct SDL_Window:
        pass
    ctypedef void *SDL_GLContext
    
    enum:
        SDL_WINDOW_OPENGL
        SDL_WINDOW_FULLSCREEN
        SDL_WINDOW_FULLSCREEN_DESKTOP
        SDL_GL_RED_SIZE
        SDL_GL_GREEN_SIZE
        SDL_GL_BLUE_SIZE
        SDL_GL_ALPHA_SIZE
        SDL_GL_MULTISAMPLEBUFFERS
        SDL_GL_MULTISAMPLESAMPLES
        SDL_GL_CONTEXT_MAJOR_VERSION
        SDL_GL_CONTEXT_MINOR_VERSION
        SDL_GL_CONTEXT_PROFILE_MASK
        SDL_GL_CONTEXT_PROFILE_ES
    
    int SDL_WINDOWPOS_CENTERED_DISPLAY (int display)
    
    int SDL_GL_SetAttribute (int attr, int value)
    void SDL_GL_SwapWindow (SDL_Window *window)
    SDL_GLContext SDL_GL_CreateContext (SDL_Window *window)
    void SDL_GL_DeleteContext (SDL_GLContext context)

    SDL_Window *SDL_CreateWindow (const char *title, int x, int y, int w, int h, int flags)
    void SDL_DestroyWindow(SDL_Window *window)
    
    const char *SDL_GetError ()
    void SDL_ClearError ()

cdef class OpenGLInterface:
    cdef SDL_Window *window
    cdef SDL_GLContext context
    
    cdef GLuint drawing_program
    
    def __init__ (self, str title = "PyDoom", int width = 640,
    int height = 480, bint fullscreen = False, bint fullwindow = False,
    int display = 0, int x = -1, int y = -1):
        """OpenGLInterface (title: str = "PyDoom", width: int = 640, height: int = 480, fullscreen: bool = False, fullwindow: bool = False, display: int = 0, x: int = -1, y: int = -1)
        
        Creates a new OpenGL context window for rendering on.
        """
        
        cdef int flags = SDL_WINDOW_OPENGL
        cdef GLenum glewstatus = 0
        cdef const char *err = NULL
        encoded_title = bytes (title, "utf8")
        
        SDL_GL_SetAttribute (SDL_GL_RED_SIZE, 8)
        SDL_GL_SetAttribute (SDL_GL_GREEN_SIZE, 8)
        SDL_GL_SetAttribute (SDL_GL_BLUE_SIZE, 8)
        SDL_GL_SetAttribute (SDL_GL_ALPHA_SIZE, 8)
        SDL_GL_SetAttribute (SDL_GL_MULTISAMPLEBUFFERS, 1)
        SDL_GL_SetAttribute (SDL_GL_MULTISAMPLESAMPLES, 4)
        SDL_GL_SetAttribute (SDL_GL_CONTEXT_MAJOR_VERSION, 3)
        SDL_GL_SetAttribute (SDL_GL_CONTEXT_MINOR_VERSION, 0)
        SDL_GL_SetAttribute (SDL_GL_CONTEXT_PROFILE_MASK,
            SDL_GL_CONTEXT_PROFILE_ES)
        
        if x < 0:
            x = SDL_WINDOWPOS_CENTERED_DISPLAY (display)
        if y < 0:
            y = SDL_WINDOWPOS_CENTERED_DISPLAY (display)
        
        if fullscreen:
            flags |= SDL_WINDOW_FULLSCREEN
        
        if fullwindow:
            flags &= ~SDL_WINDOW_FULLSCREEN
            flags |= SDL_WINDOW_FULLSCREEN_DESKTOP
        
        self.window = SDL_CreateWindow (encoded_title, x, y, width, height, flags)
        
        if not self.window:
            err = SDL_GetError ()
            SDL_ClearError ()
            raise RuntimeError (str (err, "utf8"))
        
        self.context = SDL_GL_CreateContext (self.window)
        
        if not self.context:
            err = SDL_GetError ()
            SDL_ClearError ()
            raise RuntimeError (str (err, "utf8"))
        
        # Clear to black
        glClearColor (0.0, 0.0, 0.0, 0.0)
        
        glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)
        SDL_GL_SwapWindow (self.window)
    
    def __del__ (self):
        SDL_GL_DeleteContext (self.context)
        SDL_DestroyWindow (self.window)
        self.context = NULL
        self.window = NULL
    
    def clear (self):
        glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)
    
    def swap (self):
        SDL_GL_SwapWindow (self.window)
    
    def compileProgram (self, fragShader = None, vertShader = None) -> int:
        cdef GLuint program = 0
        cdef GLint status = GL_FALSE
        cdef GLuint fragShaderID = 0, vertShaderID = 0
        
        cdef const char *fragShaderSource = NULL
        cdef const char *vertShaderSource = NULL
        
        program = glCreateProgram ()
        
        if fragShader is not None:
            fragShaderBytes = bytes (fragShader, "utf8")
            fragShaderSource = fragShaderBytes
            fragShaderID = glCreateShader (GL_FRAGMENT_SHADER)
            glShaderSource (fragShaderID, 1, <const GLchar **> fragShaderSource, NULL)
            glGetShaderiv (fragShaderID, GL_COMPILE_STATUS, &status)
            glAttachShader (program, fragShaderID)
        
        if vertShader is not None:
            vertShaderBytes = bytes (vertShader, "utf8")
            vertShaderSource = vertShaderBytes
            vertShaderID = glCreateShader (GL_VERTEX_SHADER)
            glShaderSource (vertShaderID, 1, <const GLchar **> vertShaderSource, NULL)
            glGetShaderiv (vertShaderID, GL_COMPILE_STATUS, &status)
            glAttachShader (program, vertShaderID)
        
        glLinkProgram (program)
        glGetProgramiv (program, GL_LINK_STATUS, &status)
        
        if fragShader is not None:
            glDetachShader (program, fragShaderID)
            glDeleteShader (fragShaderID)
        
        if vertShader is not None:
            glDetachShader (program, vertShaderID)
            glDeleteShader (vertShaderID)
        
        return program
    
    def useProgram (self, unsigned int program):
        self.drawing_program = program

    # TODO: Finish these
    #~ unsigned int vid_loadtexture (int width, int height, const unsigned char *data)
    #~ {
        #~ GLuint newtex;
        #~ GLuint lastTexture = 0;

        #~ // Image data is assumed provided to us as RGBA8.

        #~ glGetIntegerv (GL_TEXTURE_BINDING_2D, (GLint*) &lastTexture);

        #~ glGenTextures (1, &newtex);
        #~ glBindTexture (GL_TEXTURE_2D, newtex);

        #~ glPixelStorei (GL_UNPACK_ALIGNMENT, 1);
        #~ glTexImage2D (GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_RGBA,
            #~ GL_UNSIGNED_BYTE, data);
        #~ glGenerateMipmap (GL_TEXTURE_2D);
        #~ glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        #~ glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
            #~ GL_NEAREST_MIPMAP_NEAREST);
        
        #~ if (GL_EXT_texture_filter_anisotropic)
        #~ {
            #~ GLfloat animax;
            #~ glGetFloatv (GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &animax);
            #~ glTexParameterf (GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, animax);
        #~ }
        
        #~ glBindTexture (GL_TEXTURE_2D, lastTexture);

        #~ return newtex;
    #~ }

    #~ void vid_unloadtexture (unsigned int tex)
    #~ {
        #~ glDeleteTextures (1, &tex);
    #~ }

    #~ void vid_draw2d (unsigned int tex, float left, float top, float width,
        #~ float height)
    #~ {
        #~ glBindTexture (GL_TEXTURE_2D, tex);
    #~ }

cdef class ImageSurface:
    cdef size_t width
    cdef size_t height
    cdef const char *name
    cdef unsigned char *data
    
    def __init__ (self, str name, size_t width, size_t height):
        if width < 1 or height < 1:
            raise ValueError ("Image surface must have a valid width and height")
        
        encoded_name = bytes (name, "utf8")
        
        self.name = encoded_name
        self.width = width
        self.height = height
        cdef size_t arraysize = width * height * 4
        
        self.data = <unsigned char *> PyMem_Malloc (arraysize * sizeof (unsigned char))
        
        if self.data == NULL:
            raise MemoryError ("Could not allocate memory for surface")
        
        cdef size_t i = 0
        while i < arraysize:
            self.data[i] = 0
            i += 1
    
    cpdef unsigned int getPixel (self, size_t x, size_t y) except? 0:
        if x < 0 or y < 0 or x > self.width or y > self.height:
            return 0
        
        cdef size_t startofs = ((y * self.width) + x) * 4
        
        cdef unsigned int color = (
                (self.data[startofs]     << 24) +
                (self.data[startofs + 1] << 16) +
                (self.data[startofs + 2] << 8) +
                self.data[startofs + 3]
            )
        
        return color
    
    cpdef void setPixel (self, size_t x, size_t y, unsigned int color = 0):
        if x < 0 or y < 0 or x > self.width or y > self.height:
            return
        
        cdef size_t startofs = ((y * self.width) + x) * 4
        
        self.data[startofs]     = (color >> 24) & 0xFF
        self.data[startofs + 1] = (color >> 16) & 0xFF
        self.data[startofs + 2] = (color >>  8) & 0xFF
        self.data[startofs + 3] =  color        & 0xFF
    
    def __del__ (self):
        PyMem_Free (self.data)

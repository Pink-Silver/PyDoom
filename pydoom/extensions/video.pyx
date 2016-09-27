# Copyright (c) 2014, Kate Fox
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free

from cpython cimport array

cdef extern from "defines.h":
    pass

cdef extern from "<GL/gl.h>":
    ctypedef unsigned int GLenum
    ctypedef unsigned int GLuint
    ctypedef int GLint
    ctypedef int GLsizei
    ctypedef ptrdiff_t GLintptr
    ctypedef char GLchar
    ctypedef void GLvoid
    ctypedef float GLfloat
    ctypedef ptrdiff_t GLsizeiptr
    ctypedef bint GLboolean
    
    enum:
        GL_TRUE
        GL_FALSE
        
        GL_FASTEST
        GL_NICEST
        GL_DONT_CARE
        
        GL_RGBA8
        GL_RGBA
        GL_UNSIGNED_BYTE
        GL_FLOAT
        
        GL_NEAREST
        GL_NEAREST_MIPMAP_NEAREST
        
        GL_GENERATE_MIPMAP_HINT
        GL_UNPACK_ALIGNMENT
        
        GL_FRAGMENT_SHADER
        GL_VERTEX_SHADER
        
        GL_COMPILE_STATUS
        GL_LINK_STATUS
        GL_INFO_LOG_LENGTH
        
        GL_COLOR_BUFFER_BIT
        GL_DEPTH_BUFFER_BIT
        GL_STENCIL_BUFFER_BIT
        
        GL_TEXTURE_BINDING_2D
        GL_TEXTURE_2D
        GL_TEXTURE_MAG_FILTER
        GL_TEXTURE_MIN_FILTER
        
        GL_ARRAY_BUFFER
        GL_DYNAMIC_DRAW
        
        GL_TRIANGLES
        
    void glHint (GLenum target, GLenum mode)
    
    void glGetIntegerv (GLenum pname, GLint *params)
    
    GLuint glCreateShader (GLenum type)
    void glShaderSource (GLuint shader, GLsizei count, const GLchar **string,
        const GLint *length)
    void glCompileShader (GLuint shader)
    void glGetShaderiv (GLuint shader, GLenum pname, GLint *params)
    void glGetShaderInfoLog (GLuint shader, GLsizei maxLength, GLsizei *length,
        GLchar *infoLog)
    void glDeleteShader (GLuint shader)
    
    GLuint glCreateProgram ()
    void glAttachShader (GLuint program, GLuint shader)
    void glDetachShader (GLuint program, GLuint shader)
    void glLinkProgram (GLuint program)
    void glGetProgramiv (GLuint program, GLenum pname, GLint *params)
    void glDeleteProgram (GLuint program)
    void glUseProgram (GLuint program)

    void glClearColor (float red, float green, float blue, float alpha)
    void glClear (int mask)
    
    void glGenTextures (GLsizei n, GLuint *textures)
    void glBindTexture (GLenum target, GLuint texture)
    void glTexImage2D (GLenum target, GLint level, GLint internalformat,
        GLsizei width, GLsizei height, GLint border, GLenum format,
        GLenum type, const GLvoid *data)
    void glTexParameteri (GLenum target, GLenum pname, GLint param)
    void glPixelStorei (GLenum pname, GLint param)
    void glGenerateMipmap (GLenum target)
    void glDeleteTextures (GLsizei n, const GLuint *textures)
    
    void glGenBuffers (GLsizei n, GLuint *buffers)
    void glBufferData (GLenum target, GLsizeiptr size, const GLvoid *data,
        GLenum usage)
    void glBufferSubData (GLenum target, GLintptr offset, GLsizeiptr size,
        const GLvoid *data)
    void glBindBuffer (GLenum target, GLuint buffer)
    
    void glEnableVertexAttribArray (GLuint index)
    void glDisableVertexAttribArray (GLuint index)
    void glVertexAttribPointer (GLuint index, GLint size, GLenum type,
        GLboolean normalized, GLsizei stride, const GLvoid *pointer)
    void glDrawArrays (GLenum mode, GLint first, GLsizei count)
    
    void glFinish ()
    GLenum glGetError ()
    
cdef extern from "<GL/glext.h>":
    pass

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
    
    cdef float spriteBuffer[18]
    cdef float spriteBufferUVs[12]
    cdef GLuint spriteBufferID
    cdef GLuint spriteBufferUVsID
    
    cdef GLuint drawProgram2D
    cdef GLuint drawProgram3D
    
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
        SDL_GL_SetAttribute (SDL_GL_CONTEXT_MINOR_VERSION, 2)
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
        
        # Initial hints and setup
        glHint (GL_GENERATE_MIPMAP_HINT, GL_NICEST)
        
        self.spriteBuffer = <float *> PyMem_Malloc (18 * sizeof (float))
        cdef int i = 0
        while i < 18:
            self.spriteBuffer[i] = 0
            i += 1
        i = 0
        while i < 12:
            self.spriteBufferUVs[i] = 0
            i += 1
        
        glGenBuffers (1, &self.spriteBufferID)
        glBindBuffer (GL_ARRAY_BUFFER, self.spriteBufferID)
        glBufferData (GL_ARRAY_BUFFER, 18 * sizeof (float),
            <const void *>self.spriteBuffer, GL_DYNAMIC_DRAW)

        glGenBuffers (1, &self.spriteBufferUVsID)
        glBindBuffer (GL_ARRAY_BUFFER, self.spriteBufferUVsID)
        glBufferData (GL_ARRAY_BUFFER, 12 * sizeof (float),
            <const void *>self.spriteBufferUVs, GL_DYNAMIC_DRAW)
        
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
        glFinish ()
        SDL_GL_SwapWindow (self.window)
    
    def compileProgram (self, fragShader = None, vertShader = None) -> int:
        cdef GLuint program = 0
        cdef GLint status = GL_FALSE
        cdef GLuint fragShaderID = 0, vertShaderID = 0
        
        cdef const char *fragShaderSource = NULL
        cdef const char *vertShaderSource = NULL
        
        cdef int infoLogLength = 0
        cdef char *infoLog = NULL
        cdef int outLogLength = 0
        
        program = glCreateProgram ()
        
        if fragShader is not None:
            fragShaderBytes = bytes (fragShader, "utf8")
            fragShaderSource = fragShaderBytes
            fragShaderID = glCreateShader (GL_FRAGMENT_SHADER)
            glShaderSource (fragShaderID, 1, &fragShaderSource, NULL)
            glCompileShader (fragShaderID)
            glGetShaderiv (fragShaderID, GL_COMPILE_STATUS, &status)
            glAttachShader (program, fragShaderID)

            if status != GL_TRUE:
                glGetShaderiv (fragShaderID, GL_INFO_LOG_LENGTH, &infoLogLength)
                infoLog = <char *> PyMem_Malloc (infoLogLength * sizeof (char))
                for i in range (0, infoLogLength):
                    infoLog[i] = b'\x00'
                glGetShaderInfoLog (fragShaderID, infoLogLength, &outLogLength, infoLog)
                raise RuntimeError ("Fragment shader failed to compile:\n" + str (infoLog, "utf8"))
        
        if vertShader is not None:
            vertShaderBytes = bytes (vertShader, "utf8")
            vertShaderSource = vertShaderBytes
            vertShaderID = glCreateShader (GL_VERTEX_SHADER)
            glShaderSource (vertShaderID, 1, &vertShaderSource, NULL)
            glCompileShader (vertShaderID)
            glGetShaderiv (vertShaderID, GL_COMPILE_STATUS, &status)
            glAttachShader (program, vertShaderID)

            if status != GL_TRUE:
                glGetShaderiv (vertShaderID, GL_INFO_LOG_LENGTH, &infoLogLength)
                infoLog = <char *> PyMem_Malloc (infoLogLength * sizeof (char))
                for i in range (0, infoLogLength):
                    infoLog[i] = b'\x00'
                glGetShaderInfoLog (vertShaderID, infoLogLength, &outLogLength, infoLog)
                raise RuntimeError ("Vertex shader failed to compile:\n" + str (infoLog, "utf8"))
        
        glLinkProgram (program)
        glGetProgramiv (program, GL_LINK_STATUS, &status)

        if status != GL_TRUE:
            raise RuntimeError ("Shader program did not link properly")
        
        if fragShader is not None:
            glDetachShader (program, fragShaderID)
            glDeleteShader (fragShaderID)
        
        if vertShader is not None:
            glDetachShader (program, vertShaderID)
            glDeleteShader (vertShaderID)
        
        return program
    
    def useProgram2D (self, unsigned int program):
        self.drawProgram2D = program

    def useProgram3D (self, unsigned int program):
        self.drawProgram3D = program

    # TODO: Finish these
    def loadTexture (self, int width, int height, const unsigned char *data):
        cdef GLuint newtex = 0
        cdef GLuint lastTexture = 0

        # Image data is assumed provided to us as RGBA8.

        glGetIntegerv (GL_TEXTURE_BINDING_2D, <GLint*> &lastTexture)

        glGenTextures (1, &newtex)
        glBindTexture (GL_TEXTURE_2D, newtex)

        glPixelStorei (GL_UNPACK_ALIGNMENT, 1)
        glTexImage2D (GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_RGBA,
            GL_UNSIGNED_BYTE, data)
        glGenerateMipmap (GL_TEXTURE_2D)
        glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
        glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
            GL_NEAREST_MIPMAP_NEAREST)
        
        glBindTexture (GL_TEXTURE_2D, lastTexture)

        return newtex

    def unloadTexture (self, unsigned int tex):
        glDeleteTextures (1, &tex)

    def drawHud (self, unsigned int tex, float left, float top, float width,
    float height):
        # TODO
        
        # 2D array for drawing sprites
        self.spriteBuffer[0:18] = [
            left+width, top+height, 0,
            left+width, top, 0,
            left, top, 0,
            left, top, 0,
            left, top+height, 0,
            left+width, top+height, 0
        ]
        
        # And UVs
        self.spriteBufferUVs[0:12] = [
            1, 0,
            1, 1,
            0, 1,
            0, 1,
            0, 0,
            1, 0
        ]
        
        glUseProgram (self.drawProgram2D)

        glBindTexture (GL_TEXTURE_2D, tex)
        
        glEnableVertexAttribArray (0)
        
        glBindBuffer (GL_ARRAY_BUFFER, self.spriteBufferID)
        glBufferSubData (GL_ARRAY_BUFFER, 0,
            18 * sizeof(float),
            <const GLvoid *>self.spriteBuffer)
        glVertexAttribPointer (0, 3, GL_FLOAT, GL_FALSE, 0, <void *>0)

        glEnableVertexAttribArray (1)

        glBindBuffer (GL_ARRAY_BUFFER, self.spriteBufferUVsID)
        glBufferSubData (GL_ARRAY_BUFFER, 0,
            12 * sizeof(float),
            <const GLvoid *>self.spriteBufferUVs)
        glVertexAttribPointer (1, 2, GL_FLOAT, GL_FALSE, 0, <void *>0)
        
        glDrawArrays(GL_TRIANGLES, 0, 6)
        
        glDisableVertexAttribArray(0)
        glDisableVertexAttribArray(1)

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

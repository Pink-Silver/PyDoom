#!python3
#cython: language_level=3

# Copyright (c) 2016, Kate Fox
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free
from libc.string cimport memcpy

from cpython cimport array
import array

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
    void glGetProgramInfoLog (GLuint program, GLsizei maxLength,
        GLsizei *length, GLchar *infoLog)
    void glDeleteProgram (GLuint program)
    void glUseProgram (GLuint program)
    void glDeleteProgram (GLuint program)

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
    int SDL_GL_MakeCurrent (SDL_Window* window, SDL_GLContext context)

    SDL_Window *SDL_CreateWindow (const char *title, int x, int y, int w,
        int h, int flags)
    void SDL_DestroyWindow(SDL_Window *window)
    
    const char *SDL_GetError ()
    void SDL_ClearError ()

cdef class ImageSurface:
    cdef size_t width
    cdef size_t height
    cdef public int xoffset
    cdef public int yoffset
    cdef unsigned char *data
    
    @property
    def width (self):
        return self.width

    @property
    def height (self):
        return self.height

    def __cinit__ (self, size_t width, size_t height):
        """Provides C-level allocation of data structures."""
        
        if width < 1 or height < 1:
            raise ValueError ("Image surface must have a valid width and \
height")
        
        self.width = width
        self.height = height
        cdef size_t arraysize = width * height * 4
        
        self.data = <unsigned char *> PyMem_Malloc (arraysize *
            sizeof (unsigned char))
        
        if self.data == NULL:
            raise MemoryError ("Could not allocate memory for surface")
        
        cdef size_t i = 0
        while i < arraysize:
            self.data[i] = 0
            i += 1
    
    def __dealloc__ (self):
        """Implements ImageSurface deletion."""
        
        PyMem_Free (self.data)

    def __init__ (self, size_t width, size_t height):
        """ImageSurface (width, height) -> ImageSurface
        
        Creates a new ImageSurface that can be used to load and modify OpenGL
        textures."""
        
        pass
    
    def getPixel (self, size_t x, size_t y) -> tuple:
        """I.getPixel (x, y) -> tuple
        
        Returns a color as a (red, green, blue, alpha) tuple."""
        
        if x < 0 or y < 0 or x > self.width or y > self.height:
            return 0
        
        cdef size_t startofs = ((y * self.width) + x) * 4
        
        color = (
            self.data[startofs],
            self.data[startofs + 1],
            self.data[startofs + 2],
            self.data[startofs + 3]
        )
        
        return color
    
    def setPixel (self, size_t x, size_t y, color=(0, 0, 0, 0)):
        """I.setPixel (x, y[, color])
        
        Sets the corresponding pixel to the provided color. If the color is
        omitted, transparent is assumed."""
        
        if x < 0 or y < 0 or x > self.width or y > self.height:
            return
        
        cdef size_t startofs = ((y * self.width) + x) * 4
        
        self.data[startofs]     = color[0]
        self.data[startofs + 1] = color[1]
        self.data[startofs + 2] = color[2]
        self.data[startofs + 3] = color[3]
    
    cdef void setPixelDirect (self, size_t x, size_t y, unsigned int color):
        if x < 0 or y < 0 or x > self.width or y > self.height:
            return
        
        cdef size_t startofs = ((y * self.width) + x) * 4
        
        self.data[startofs]     = (color & 0xFF000000U) >> 24
        self.data[startofs + 1] = (color & 0x00FF0000U) >> 16
        self.data[startofs + 2] = (color & 0x0000FF00U) >> 8
        self.data[startofs + 3] = (color & 0x000000FFU)
    
    ### Image Readers ###

    @classmethod
    def LoadDoomGraphic (cls, bytes bytebuffer, bytes palette):
        """Loads a top-down column-based paletted doom graphic, given the
        graphic's binary data and a palette. Returns an Image usable
        with the OpenGL context."""
        cdef int pos = 0
        
        cdef short width, height, xofs, yofs
        
        cdef size_t bytebuflen = len(bytebuffer)
        cdef unsigned char *rawbuffer = bytebuffer
        cdef unsigned char *rawpalette = palette
        
        width  = rawbuffer[pos+0]
        width |= rawbuffer[pos+1] << 8
        pos += 2

        height  = rawbuffer[pos+0]
        height |= rawbuffer[pos+1] << 8
        pos += 2
        
        xofs  = rawbuffer[pos+0]
        xofs |= rawbuffer[pos+1] << 8
        pos += 2

        yofs  = rawbuffer[pos+0]
        yofs |= rawbuffer[pos+1] << 8
        pos += 2

        cdef ImageSurface image = cls (width, height)
        
        image.xoffset = xofs
        image.yoffset = yofs

        colheaders = []

        cdef unsigned int byte_ofs
        cdef int column
        
        cdef int lastrowstart
        cdef int rowstart
        cdef int byteofs
        cdef int columnlength
        cdef int palindex
        cdef int rowpos
        cdef unsigned int palcolor
        
        # The headers for each column
        for colheader in range (width):
            byte_ofs  = rawbuffer[pos+0]
            byte_ofs |= rawbuffer[pos+1]
            byte_ofs |= rawbuffer[pos+2]
            byte_ofs |= rawbuffer[pos+3]
            colheaders.append (byte_ofs)
            pos += 4

        # Okay, so in the standard graphic format, if the last row
        # started in the same column is above or at the height last
        # drawn, they'd usually be drawn above or on top of the column
        # we just drew (which would be a waste of space since we're just
        # drawing on top of pixels we've *just* drawn).

        # Instead, what we do is *add* the last offset to our current
        # one, so we're always drawing in new space instead. This gives
        # us twice the column height to work with, allowing graphic
        # columns to start from up to the 512th row instead of the
        # 256th. This means transparent images that are > 256 in height
        # won't corrupt.

        for column in range (width):
            lastrowstart = -1
            rowstart = 0
            byteofs = colheaders[column]
            while True:
                rowstart = rawbuffer[byteofs]
                byteofs += 1

                if rowstart == 255:
                    # No more pieces to draw, go to next column
                    break

                if rowstart <= lastrowstart:
                    rowstart += lastrowstart

                columnlength = rawbuffer[byteofs]
                byteofs += 2

                for rowpos in range (columnlength):
                    palindex = rawbuffer[byteofs]
                    byteofs += 1

                    palcolor = 0xFF
                    palcolor |= rawpalette[2] << 8
                    palcolor |= rawpalette[1] << 16
                    palcolor |= rawpalette[0] << 24
                    image.setPixelDirect (column, rowpos + rowstart, palcolor)

                byteofs += 1
                lastrowstart = rowstart

        PyMem_Free (rawbuffer)
        return image

    @classmethod
    def LoadPNG (cls, bytebuffer):
        """Loads a Portable Network Graphic."""

        #decompressor = zlib.decompressobj ()

        if bytebuffer[0:8] != b'\x89PNG\r\n\x1a\n':
            raise ValueError ("The PNG header is corrupted")

        # TODO
        pass

cdef class OpenGLWindow:
    cdef SDL_Window *window
    cdef SDL_GLContext context
    
    cdef dict textures
    cdef dict shaderPrograms
    
    cdef float spriteBuffer[18]
    cdef float spriteBufferUVs[12]
    cdef GLuint spriteBufferID
    cdef GLuint spriteBufferUVsID
    
    cdef GLuint drawProgram2D
    cdef GLuint drawProgram3D
    
    def __init__ (self, str title="PyDoom", int width=640,
    int height=480, bint fullscreen=False, bint fullwindow=False,
    int display=0, int x=-1, int y=-1):
        """OpenGLInterface (title="PyDoom", width=640, height=480,
        fullscreen=False, fullwindow=False, display=0, x=-1,
        y=-1) -> OpenGLInterface
        
        Creates a new OpenGL context window for rendering on.
        """
        
        self.textures = {}
        self.shaderPrograms = {}
        
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
        
        self.window = SDL_CreateWindow (encoded_title, x, y, width, height,
            flags)
        
        if not self.window:
            err = SDL_GetError ()
            SDL_ClearError ()
            raise RuntimeError (str (err, "utf8"))
        
        self.context = SDL_GL_CreateContext (self.window)
        
        if not self.context:
            err = SDL_GetError ()
            SDL_ClearError ()
            raise RuntimeError (str (err, "utf8"))
        
        SDL_GL_MakeCurrent (self.window, self.context)
        
        # Initial hints and setup
        glHint (GL_GENERATE_MIPMAP_HINT, GL_NICEST)
        
        self.spriteBuffer = <float *> PyMem_Malloc (18 * sizeof (float))
        cdef int i = 0
        for i in range (18):
            self.spriteBuffer[i] = 0
        for i in range (12):
            self.spriteBufferUVs[i] = 0
        
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
        
        glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT |
            GL_STENCIL_BUFFER_BIT)
        SDL_GL_SwapWindow (self.window)
    
    def __del__ (self):
        """Implements OpenGLInterface deletion."""
        
        SDL_GL_DeleteContext (self.context)
        SDL_DestroyWindow (self.window)
        self.context = NULL
        self.window = NULL
    
    def clear (self):
        """W.clear ()
        
        Clears the screen."""
        
        SDL_GL_MakeCurrent (self.window, self.context)
        
        glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT |
            GL_STENCIL_BUFFER_BIT)
    
    def swap (self):
        """W.swap ()
        
        Waits for the frame to fully render, then swaps the screen buffers."""
        
        SDL_GL_MakeCurrent (self.window, self.context)
        
        glFinish ()
        SDL_GL_SwapWindow (self.window)
    
    def compileProgram (self, str name, str fragShader, str vertShader):
        """W.compileProgram (name, fragShader, vertShader)
        
        Compiles a shader program from sources, provided as strings."""
        
        cdef GLuint program = 0
        cdef GLint status = GL_FALSE
        cdef GLuint fragShaderID = 0, vertShaderID = 0
        
        cdef const char *fragShaderSource = NULL
        cdef const char *vertShaderSource = NULL
        
        cdef int infoLogLength = 0
        cdef char *infoLog = NULL
        cdef int outLogLength = 0
        
        SDL_GL_MakeCurrent (self.window, self.context)
        
        program = glCreateProgram ()

        fragShaderBytes = bytes (fragShader, "utf8")
        fragShaderSource = fragShaderBytes
        fragShaderID = glCreateShader (GL_FRAGMENT_SHADER)
        glShaderSource (fragShaderID, 1, &fragShaderSource, NULL)
        glCompileShader (fragShaderID)
        glGetShaderiv (fragShaderID, GL_COMPILE_STATUS, &status)
        glAttachShader (program, fragShaderID)

        if status != GL_TRUE:
            glGetShaderiv (fragShaderID, GL_INFO_LOG_LENGTH,
                &infoLogLength)
            infoLogStr = "unknown error"
            if infoLogLength > 0:
                infoLog = <char *> PyMem_Malloc (infoLogLength *
                    sizeof (char))
                for i in range (0, infoLogLength):
                    infoLog[i] = b'\x00'
                glGetShaderInfoLog (fragShaderID, infoLogLength,
                    &outLogLength, infoLog)
                infoLogStr = str (infoLog, "utf8")
                PyMem_Free (infoLog)
            raise RuntimeError ("Fragment shader failed to compile:\n" +
                infoLogStr)
        
        vertShaderBytes = bytes (vertShader, "utf8")
        vertShaderSource = vertShaderBytes
        vertShaderID = glCreateShader (GL_VERTEX_SHADER)
        glShaderSource (vertShaderID, 1, &vertShaderSource, NULL)
        glCompileShader (vertShaderID)
        glGetShaderiv (vertShaderID, GL_COMPILE_STATUS, &status)
        glAttachShader (program, vertShaderID)

        if status != GL_TRUE:
            glGetShaderiv (vertShaderID, GL_INFO_LOG_LENGTH,
                &infoLogLength)
            infoLogStr = "unknown error"
            if infoLogLength > 0:
                infoLog = <char *> PyMem_Malloc (infoLogLength *
                    sizeof (char))
                for i in range (0, infoLogLength):
                    infoLog[i] = b'\x00'
                glGetShaderInfoLog (vertShaderID, infoLogLength,
                    &outLogLength, infoLog)
                infoLogStr = str (infoLog, "utf8")
                PyMem_Free (infoLog)
            raise RuntimeError ("Vertex shader failed to compile:\n" +
                infoLogStr)
        
        glLinkProgram (program)
        glGetProgramiv (program, GL_LINK_STATUS, &status)

        if status != GL_TRUE:
            glGetProgramiv (program, GL_INFO_LOG_LENGTH,
                &infoLogLength)
            infoLogStr = "unknown error"
            if infoLogLength > 0:
                infoLog = <char *> PyMem_Malloc (infoLogLength *
                    sizeof (char))
                for i in range (0, infoLogLength):
                    infoLog[i] = b'\x00'
                glGetProgramInfoLog (program, infoLogLength,
                    &outLogLength, infoLog)
                infoLogStr = str (infoLog, "utf8")
                PyMem_Free (infoLog)
            raise RuntimeError ("Shader Program failed to link:\n" +
                infoLogStr)
        
        if fragShader is not None:
            glDetachShader (program, fragShaderID)
            glDeleteShader (fragShaderID)
        
        if vertShader is not None:
            glDetachShader (program, vertShaderID)
            glDeleteShader (vertShaderID)
        
        self.shaderPrograms[name] = program
    
    def unloadProgram (self, str name):
        """W.unloadProgram (name)
        
        Frees up the previously loaded shader program specified by name."""
        cdef GLuint programID
        programID = self.shaderPrograms[name]
        
        SDL_GL_MakeCurrent (self.window, self.context)
        
        glDeleteProgram (programID)
        del self.shaderPrograms[name]

    def useProgram2D (self, str name):
        """W.useProgram2D (name)
        
        Specifies the OpenGL Shader Program to use for 2-dimensional
        drawing by name."""
        self.drawProgram2D = self.shaderPrograms[name]

    def useProgram3D (self, str name):
        """W.useProgram3D (name)
        
        Specifies the OpenGL Shader Program to use for 3-dimensional
        drawing by name."""
        self.drawProgram3D = self.shaderPrograms[name]

    # TODO: Finish these
    def loadTexture (self, str name, ImageSurface image):
        """W.loadTexture (name, image)
        
        Transforms image into a texture and stores it into video memory, which
        can then be referenced by name in future drawing operations."""
        
        cdef GLuint newtex = 0
        cdef GLuint lastTexture = 0
        
        SDL_GL_MakeCurrent (self.window, self.context)

        # Image data is assumed provided to us as RGBA8.

        glGetIntegerv (GL_TEXTURE_BINDING_2D, <GLint*> &lastTexture)

        glGenTextures (1, &newtex)
        glBindTexture (GL_TEXTURE_2D, newtex)

        glPixelStorei (GL_UNPACK_ALIGNMENT, 1)
        glTexImage2D (GL_TEXTURE_2D, 0, GL_RGBA8, image.width, image.height, 0,
            GL_RGBA, GL_UNSIGNED_BYTE, image.data)
        glGenerateMipmap (GL_TEXTURE_2D)
        glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
        glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
            GL_NEAREST_MIPMAP_NEAREST)
        
        glBindTexture (GL_TEXTURE_2D, lastTexture)
        
        self.textures[name] = newtex

    def unloadTexture (self, str name):
        """W.unloadTexture (name)
        
        Frees up the previously loaded texture specified by name."""
        cdef GLuint textureID
        textureID = self.textures[name]
        
        SDL_GL_MakeCurrent (self.window, self.context)
        
        glDeleteTextures (1, &textureID)
        del self.textures[name]

    def drawHud (self, str texture, float left, float top, float width,
    float height):
        """W.drawHud (texture, left, top, width, height)
        
        Draws a 2-dimensional HUD element on the screen, using the graphic
        specified by texture. left and top are offsets from the edges from the
        screen, with 1.0 being the right and bottom. width and height are
        relative dimensions of the image to draw, with 1.0 being the full
        screen size."""
        
        # 3D vertex array for the sprite's tris
        self.spriteBuffer[0:18] = [
            left+width, 1.0 - (top+height), 0,
            left+width, 1.0 - top,          0,
            left,       1.0 - top,          0,
            
            left,       1.0 - top,          0,
            left,       1.0 - (top+height), 0,
            left+width, 1.0 - (top+height), 0
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
        
        SDL_GL_MakeCurrent (self.window, self.context)
        
        glUseProgram (self.drawProgram2D)

        glBindTexture (GL_TEXTURE_2D, self.textures[texture])
        
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

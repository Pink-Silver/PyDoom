# No copyright header this time because this isn't actually from SDL, it's all
# OpenGL prototypes. OpenGL belongs to SGI and The Khronos Group.

cdef extern from "SDL_opengl.h":
    # basic types
    ctypedef unsigned int GLenum
    ctypedef unsigned char GLboolean
    ctypedef unsigned int GLbitfield
    ctypedef signed char GLbyte
    ctypedef short GLshort
    ctypedef int GLint
    ctypedef int GLsizei
    ctypedef unsigned char GLubyte
    ctypedef unsigned short GLushort
    ctypedef unsigned int GLuint
    ctypedef float GLfloat
    ctypedef float GLclampf
    ctypedef double GLdouble
    ctypedef double GLclampd
    ctypedef void GLvoid

    # defines
    enum: GL_VERSION_1_1

    enum: GL_ACCUM
    enum: GL_LOAD
    enum: GL_RETURN
    enum: GL_MULT
    enum: GL_ADD

    enum: GL_NEVER
    enum: GL_LESS
    enum: GL_EQUAL
    enum: GL_LEQUAL
    enum: GL_GREATER
    enum: GL_NOTEQUAL
    enum: GL_GEQUAL
    enum: GL_ALWAYS

    enum: GL_CURRENT_BIT
    enum: GL_POINT_BIT
    enum: GL_LINE_BIT
    enum: GL_POLYGON_BIT
    enum: GL_POLYGON_STIPPLE_BIT
    enum: GL_PIXEL_MODE_BIT
    enum: GL_LIGHTING_BIT
    enum: GL_FOG_BIT
    enum: GL_DEPTH_BUFFER_BIT
    enum: GL_ACCUM_BUFFER_BIT
    enum: GL_STENCIL_BUFFER_BIT
    enum: GL_VIEWPORT_BIT
    enum: GL_TRANSFORM_BIT
    enum: GL_ENABLE_BIT
    enum: GL_COLOR_BUFFER_BIT
    enum: GL_HINT_BIT
    enum: GL_EVAL_BIT
    enum: GL_LIST_BIT
    enum: GL_TEXTURE_BIT
    enum: GL_SCISSOR_BIT
    enum: GL_ALL_ATTRIB_BITS

    enum: GL_POINTS
    enum: GL_LINES 
    enum: GL_LINE_LOOP
    enum: GL_LINE_STRIP
    enum: GL_TRIANGLES
    enum: GL_TRIANGLE_STRIP
    enum: GL_TRIANGLE_FAN
    enum: GL_QUADS
    enum: GL_QUAD_STRIP
    enum: GL_POLYGON

    enum: GL_ZERO
    enum: GL_ONE
    enum: GL_SRC_COLOR
    enum: GL_ONE_MINUS_SRC_COLOR
    enum: GL_SRC_ALPHA
    enum: GL_ONE_MINUS_SRC_ALPHA
    enum: GL_DST_ALPHA
    enum: GL_ONE_MINUS_DST_ALPHA

    enum: GL_DST_COLOR
    enum: GL_ONE_MINUS_DST_COLOR
    enum: GL_SRC_ALPHA_SATURATE

    enum: GL_TRUE
    enum: GL_FALSE

    enum: GL_CLIP_PLANE0
    enum: GL_CLIP_PLANE1
    enum: GL_CLIP_PLANE2
    enum: GL_CLIP_PLANE3
    enum: GL_CLIP_PLANE4
    enum: GL_CLIP_PLANE5

    enum: GL_BYTE
    enum: GL_UNSIGNED_BYTE
    enum: GL_SHORT
    enum: GL_UNSIGNED_SHORT
    enum: GL_INT
    enum: GL_UNSIGNED_INT
    enum: GL_FLOAT
    enum: GL_2_BYTES
    enum: GL_3_BYTES
    enum: GL_4_BYTES
    enum: GL_DOUBLE

    enum: GL_NONE
    enum: GL_FRONT_LEFT
    enum: GL_FRONT_RIGHT
    enum: GL_BACK_LEFT
    enum: GL_BACK_RIGHT
    enum: GL_FRONT
    enum: GL_BACK
    enum: GL_LEFT
    enum: GL_RIGHT
    enum: GL_FRONT_AND_BACK
    enum: GL_AUX0
    enum: GL_AUX1
    enum: GL_AUX2
    enum: GL_AUX3

    enum: GL_NO_ERROR
    enum: GL_INVALID_ENUM
    enum: GL_INVALID_VALUE
    enum: GL_INVALID_OPERATION
    enum: GL_STACK_OVERFLOW
    enum: GL_STACK_UNDERFLOW
    enum: GL_OUT_OF_MEMORY

    enum: GL_2D
    enum: GL_3D
    enum: GL_3D_COLOR
    enum: GL_3D_COLOR_TEXTURE
    enum: GL_4D_COLOR_TEXTURE

    enum: GL_PASS_THROUGH_TOKEN
    enum: GL_POINT_TOKEN
    enum: GL_LINE_TOKEN
    enum: GL_POLYGON_TOKEN
    enum: GL_BITMAP_TOKEN
    enum: GL_DRAW_PIXEL_TOKEN
    enum: GL_COPY_PIXEL_TOKEN
    enum: GL_LINE_RESET_TOKEN

    enum: GL_EXP
    enum: GL_EXP2

    enum: GL_CW
    enum: GL_CCW

    enum: GL_COEFF
    enum: GL_ORDER
    enum: GL_DOMAIN

    enum: GL_CURRENT_COLOR
    enum: GL_CURRENT_INDEX
    enum: GL_CURRENT_NORMAL
    enum: GL_CURRENT_TEXTURE_COORDS
    enum: GL_CURRENT_RASTER_COLOR
    enum: GL_CURRENT_RASTER_INDEX
    enum: GL_CURRENT_RASTER_TEXTURE_COORDS
    enum: GL_CURRENT_RASTER_POSITION
    enum: GL_CURRENT_RASTER_POSITION_VALID
    enum: GL_CURRENT_RASTER_DISTANCE
    enum: GL_POINT_SMOOTH
    enum: GL_POINT_SIZE
    enum: GL_POINT_SIZE_RANGE
    enum: GL_POINT_SIZE_GRANULARITY
    enum: GL_LINE_SMOOTH
    enum: GL_LINE_WIDTH
    enum: GL_LINE_WIDTH_RANGE
    enum: GL_LINE_WIDTH_GRANULARITY
    enum: GL_LINE_STIPPLE
    enum: GL_LINE_STIPPLE_PATTERN
    enum: GL_LINE_STIPPLE_REPEAT
    enum: GL_LIST_MODE
    enum: GL_MAX_LIST_NESTING
    enum: GL_LIST_BASE
    enum: GL_LIST_INDEX
    enum: GL_POLYGON_MODE
    enum: GL_POLYGON_SMOOTH
    enum: GL_POLYGON_STIPPLE
    enum: GL_EDGE_FLAG
    enum: GL_CULL_FACE
    enum: GL_CULL_FACE_MODE
    enum: GL_FRONT_FACE
    enum: GL_LIGHTING
    enum: GL_LIGHT_MODEL_LOCAL_VIEWER
    enum: GL_LIGHT_MODEL_TWO_SIDE
    enum: GL_LIGHT_MODEL_AMBIENT
    enum: GL_SHADE_MODEL
    enum: GL_COLOR_MATERIAL_FACE
    enum: GL_COLOR_MATERIAL_PARAMETER
    enum: GL_COLOR_MATERIAL
    enum: GL_FOG
    enum: GL_FOG_INDEX
    enum: GL_FOG_DENSITY
    enum: GL_FOG_START
    enum: GL_FOG_END
    enum: GL_FOG_MODE
    enum: GL_FOG_COLOR
    enum: GL_DEPTH_RANGE
    enum: GL_DEPTH_TEST
    enum: GL_DEPTH_WRITEMASK
    enum: GL_DEPTH_CLEAR_VALUE
    enum: GL_DEPTH_FUNC
    enum: GL_ACCUM_CLEAR_VALUE
    enum: GL_STENCIL_TEST
    enum: GL_STENCIL_CLEAR_VALUE
    enum: GL_STENCIL_FUNC
    enum: GL_STENCIL_VALUE_MASK
    enum: GL_STENCIL_FAIL
    enum: GL_STENCIL_PASS_DEPTH_FAIL
    enum: GL_STENCIL_PASS_DEPTH_PASS
    enum: GL_STENCIL_REF
    enum: GL_STENCIL_WRITEMASK
    enum: GL_MATRIX_MODE
    enum: GL_NORMALIZE
    enum: GL_VIEWPORT
    enum: GL_MODELVIEW_STACK_DEPTH
    enum: GL_PROJECTION_STACK_DEPTH
    enum: GL_TEXTURE_STACK_DEPTH
    enum: GL_MODELVIEW_MATRIX
    enum: GL_PROJECTION_MATRIX
    enum: GL_TEXTURE_MATRIX
    enum: GL_ATTRIB_STACK_DEPTH
    enum: GL_CLIENT_ATTRIB_STACK_DEPTH
    enum: GL_ALPHA_TEST
    enum: GL_ALPHA_TEST_FUNC
    enum: GL_ALPHA_TEST_REF
    enum: GL_DITHER
    enum: GL_BLEND_DST
    enum: GL_BLEND_SRC
    enum: GL_BLEND
    enum: GL_LOGIC_OP_MODE
    enum: GL_INDEX_LOGIC_OP
    enum: GL_COLOR_LOGIC_OP
    enum: GL_AUX_BUFFERS
    enum: GL_DRAW_BUFFER
    enum: GL_READ_BUFFER
    enum: GL_SCISSOR_BOX
    enum: GL_SCISSOR_TEST
    enum: GL_INDEX_CLEAR_VALUE
    enum: GL_INDEX_WRITEMASK
    enum: GL_COLOR_CLEAR_VALUE
    enum: GL_COLOR_WRITEMASK
    enum: GL_INDEX_MODE
    enum: GL_RGBA_MODE
    enum: GL_DOUBLEBUFFER
    enum: GL_STEREO
    enum: GL_RENDER_MODE
    enum: GL_PERSPECTIVE_CORRECTION_HINT
    enum: GL_POINT_SMOOTH_HINT
    enum: GL_LINE_SMOOTH_HINT
    enum: GL_POLYGON_SMOOTH_HINT
    enum: GL_FOG_HINT
    enum: GL_TEXTURE_GEN_S
    enum: GL_TEXTURE_GEN_T
    enum: GL_TEXTURE_GEN_R
    enum: GL_TEXTURE_GEN_Q
    enum: GL_PIXEL_MAP_I_TO_I
    enum: GL_PIXEL_MAP_S_TO_S
    enum: GL_PIXEL_MAP_I_TO_R
    enum: GL_PIXEL_MAP_I_TO_G
    enum: GL_PIXEL_MAP_I_TO_B
    enum: GL_PIXEL_MAP_I_TO_A
    enum: GL_PIXEL_MAP_R_TO_R
    enum: GL_PIXEL_MAP_G_TO_G
    enum: GL_PIXEL_MAP_B_TO_B
    enum: GL_PIXEL_MAP_A_TO_A
    enum: GL_PIXEL_MAP_I_TO_I_SIZE
    enum: GL_PIXEL_MAP_S_TO_S_SIZE
    enum: GL_PIXEL_MAP_I_TO_R_SIZE
    enum: GL_PIXEL_MAP_I_TO_G_SIZE
    enum: GL_PIXEL_MAP_I_TO_B_SIZE
    enum: GL_PIXEL_MAP_I_TO_A_SIZE
    enum: GL_PIXEL_MAP_R_TO_R_SIZE
    enum: GL_PIXEL_MAP_G_TO_G_SIZE
    enum: GL_PIXEL_MAP_B_TO_B_SIZE
    enum: GL_PIXEL_MAP_A_TO_A_SIZE
    enum: GL_UNPACK_SWAP_BYTES
    enum: GL_UNPACK_LSB_FIRST
    enum: GL_UNPACK_ROW_LENGTH
    enum: GL_UNPACK_SKIP_ROWS
    enum: GL_UNPACK_SKIP_PIXELS
    enum: GL_UNPACK_ALIGNMENT
    enum: GL_PACK_SWAP_BYTES
    enum: GL_PACK_LSB_FIRST
    enum: GL_PACK_ROW_LENGTH
    enum: GL_PACK_SKIP_ROWS
    enum: GL_PACK_SKIP_PIXELS
    enum: GL_PACK_ALIGNMENT
    enum: GL_MAP_COLOR
    enum: GL_MAP_STENCIL
    enum: GL_INDEX_SHIFT
    enum: GL_INDEX_OFFSET
    enum: GL_RED_SCALE
    enum: GL_RED_BIAS
    enum: GL_ZOOM_X
    enum: GL_ZOOM_Y
    enum: GL_GREEN_SCALE
    enum: GL_GREEN_BIAS
    enum: GL_BLUE_SCALE
    enum: GL_BLUE_BIAS
    enum: GL_ALPHA_SCALE
    enum: GL_ALPHA_BIAS
    enum: GL_DEPTH_SCALE
    enum: GL_DEPTH_BIAS
    enum: GL_MAX_EVAL_ORDER
    enum: GL_MAX_LIGHTS
    enum: GL_MAX_CLIP_PLANES
    enum: GL_MAX_TEXTURE_SIZE
    enum: GL_MAX_PIXEL_MAP_TABLE
    enum: GL_MAX_ATTRIB_STACK_DEPTH
    enum: GL_MAX_MODELVIEW_STACK_DEPTH
    enum: GL_MAX_NAME_STACK_DEPTH
    enum: GL_MAX_PROJECTION_STACK_DEPTH
    enum: GL_MAX_TEXTURE_STACK_DEPTH
    enum: GL_MAX_VIEWPORT_DIMS
    enum: GL_MAX_CLIENT_ATTRIB_STACK_DEPTH
    enum: GL_SUBPIXEL_BITS
    enum: GL_INDEX_BITS
    enum: GL_RED_BITS
    enum: GL_GREEN_BITS
    enum: GL_BLUE_BITS
    enum: GL_ALPHA_BITS
    enum: GL_DEPTH_BITS
    enum: GL_STENCIL_BITS
    enum: GL_ACCUM_RED_BITS
    enum: GL_ACCUM_GREEN_BITS
    enum: GL_ACCUM_BLUE_BITS
    enum: GL_ACCUM_ALPHA_BITS
    enum: GL_NAME_STACK_DEPTH
    enum: GL_AUTO_NORMAL
    enum: GL_MAP1_COLOR_4
    enum: GL_MAP1_INDEX
    enum: GL_MAP1_NORMAL
    enum: GL_MAP1_TEXTURE_COORD_1
    enum: GL_MAP1_TEXTURE_COORD_2
    enum: GL_MAP1_TEXTURE_COORD_3
    enum: GL_MAP1_TEXTURE_COORD_4
    enum: GL_MAP1_VERTEX_3
    enum: GL_MAP1_VERTEX_4
    enum: GL_MAP2_COLOR_4
    enum: GL_MAP2_INDEX
    enum: GL_MAP2_NORMAL
    enum: GL_MAP2_TEXTURE_COORD_1
    enum: GL_MAP2_TEXTURE_COORD_2
    enum: GL_MAP2_TEXTURE_COORD_3
    enum: GL_MAP2_TEXTURE_COORD_4
    enum: GL_MAP2_VERTEX_3
    enum: GL_MAP2_VERTEX_4
    enum: GL_MAP1_GRID_DOMAIN
    enum: GL_MAP1_GRID_SEGMENTS
    enum: GL_MAP2_GRID_DOMAIN
    enum: GL_MAP2_GRID_SEGMENTS
    enum: GL_TEXTURE_1D
    enum: GL_TEXTURE_2D
    enum: GL_FEEDBACK_BUFFER_POINTER
    enum: GL_FEEDBACK_BUFFER_SIZE
    enum: GL_FEEDBACK_BUFFER_TYPE
    enum: GL_SELECTION_BUFFER_POINTER
    enum: GL_SELECTION_BUFFER_SIZE

    enum: GL_TEXTURE_WIDTH
    enum: GL_TEXTURE_HEIGHT
    enum: GL_TEXTURE_INTERNAL_FORMAT
    enum: GL_TEXTURE_BORDER_COLOR
    enum: GL_TEXTURE_BORDER

    enum: GL_DONT_CARE
    enum: GL_FASTEST
    enum: GL_NICEST

    enum: GL_LIGHT0
    enum: GL_LIGHT1
    enum: GL_LIGHT2
    enum: GL_LIGHT3
    enum: GL_LIGHT4
    enum: GL_LIGHT5
    enum: GL_LIGHT6
    enum: GL_LIGHT7

    enum: GL_AMBIENT
    enum: GL_DIFFUSE
    enum: GL_SPECULAR
    enum: GL_POSITION
    enum: GL_SPOT_DIRECTION
    enum: GL_SPOT_EXPONENT
    enum: GL_SPOT_CUTOFF
    enum: GL_CONSTANT_ATTENUATION
    enum: GL_LINEAR_ATTENUATION
    enum: GL_QUADRATIC_ATTENUATION

    enum: GL_COMPILE
    enum: GL_COMPILE_AND_EXECUTE

    enum: GL_CLEAR
    enum: GL_AND
    enum: GL_AND_REVERSE
    enum: GL_COPY
    enum: GL_AND_INVERTED
    enum: GL_NOOP
    enum: GL_XOR
    enum: GL_OR
    enum: GL_NOR
    enum: GL_EQUIV
    enum: GL_INVERT
    enum: GL_OR_REVERSE
    enum: GL_COPY_INVERTED
    enum: GL_OR_INVERTED
    enum: GL_NAND
    enum: GL_SET

    enum: GL_EMISSION
    enum: GL_SHININESS
    enum: GL_AMBIENT_AND_DIFFUSE
    enum: GL_COLOR_INDEXES

    enum: GL_MODELVIEW
    enum: GL_PROJECTION
    enum: GL_TEXTURE

    enum: GL_COLOR
    enum: GL_DEPTH
    enum: GL_STENCIL

    enum: GL_COLOR_INDEX
    enum: GL_STENCIL_INDEX
    enum: GL_DEPTH_COMPONENT 
    enum: GL_RED
    enum: GL_GREEN
    enum: GL_BLUE
    enum: GL_ALPHA
    enum: GL_RGB
    enum: GL_RGBA
    enum: GL_LUMINANCE
    enum: GL_LUMINANCE_ALPHA

    enum: GL_BITMAP

    enum: GL_POINT
    enum: GL_LINE
    enum: GL_FILL

    enum: GL_RENDER
    enum: GL_FEEDBACK
    enum: GL_SELECT

    enum: GL_FLAT
    enum: GL_SMOOTH

    enum: GL_KEEP
    enum: GL_REPLACE
    enum: GL_INCR
    enum: GL_DECR

    enum: GL_VENDOR
    enum: GL_RENDERER
    enum: GL_VERSION
    enum: GL_EXTENSIONS

    enum: GL_S
    enum: GL_T
    enum: GL_R
    enum: GL_Q

    enum: GL_MODULATE
    enum: GL_DECAL

    enum: GL_TEXTURE_ENV_MODE
    enum: GL_TEXTURE_ENV_COLOR

    enum: GL_TEXTURE_ENV

    enum: GL_EYE_LINEAR
    enum: GL_OBJECT_LINEAR
    enum: GL_SPHERE_MAP

    enum: GL_TEXTURE_GEN_MODE
    enum: GL_OBJECT_PLANE
    enum: GL_EYE_PLANE

    enum: GL_NEAREST
    enum: GL_LINEAR

    enum: GL_NEAREST_MIPMAP_NEAREST
    enum: GL_LINEAR_MIPMAP_NEAREST
    enum: GL_NEAREST_MIPMAP_LINEAR
    enum: GL_LINEAR_MIPMAP_LINEAR

    enum: GL_TEXTURE_MAG_FILTER
    enum: GL_TEXTURE_MIN_FILTER
    enum: GL_TEXTURE_WRAP_S
    enum: GL_TEXTURE_WRAP_T

    enum: GL_CLAMP
    enum: GL_REPEAT

    enum: GL_CLIENT_PIXEL_STORE_BIT
    enum: GL_CLIENT_VERTEX_ARRAY_BIT
    enum: GL_CLIENT_ALL_ATTRIB_BITS

    enum: GL_POLYGON_OFFSET_FACTOR
    enum: GL_POLYGON_OFFSET_UNITS
    enum: GL_POLYGON_OFFSET_POINT
    enum: GL_POLYGON_OFFSET_LINE
    enum: GL_POLYGON_OFFSET_FILL

    enum: GL_ALPHA4
    enum: GL_ALPHA8
    enum: GL_ALPHA12
    enum: GL_ALPHA16
    enum: GL_LUMINANCE4
    enum: GL_LUMINANCE8
    enum: GL_LUMINANCE12
    enum: GL_LUMINANCE16
    enum: GL_LUMINANCE4_ALPHA4
    enum: GL_LUMINANCE6_ALPHA2
    enum: GL_LUMINANCE8_ALPHA8
    enum: GL_LUMINANCE12_ALPHA4
    enum: GL_LUMINANCE12_ALPHA12
    enum: GL_LUMINANCE16_ALPHA16
    enum: GL_INTENSITY
    enum: GL_INTENSITY4
    enum: GL_INTENSITY8
    enum: GL_INTENSITY12
    enum: GL_INTENSITY16
    enum: GL_R3_G3_B2
    enum: GL_RGB4
    enum: GL_RGB5
    enum: GL_RGB8
    enum: GL_RGB10
    enum: GL_RGB12
    enum: GL_RGB16
    enum: GL_RGBA2
    enum: GL_RGBA4
    enum: GL_RGB5_A1
    enum: GL_RGBA8
    enum: GL_RGB10_A2
    enum: GL_RGBA12
    enum: GL_RGBA16
    enum: GL_TEXTURE_RED_SIZE
    enum: GL_TEXTURE_GREEN_SIZE
    enum: GL_TEXTURE_BLUE_SIZE
    enum: GL_TEXTURE_ALPHA_SIZE
    enum: GL_TEXTURE_LUMINANCE_SIZE
    enum: GL_TEXTURE_INTENSITY_SIZE
    enum: GL_PROXY_TEXTURE_1D
    enum: GL_PROXY_TEXTURE_2D

    enum: GL_TEXTURE_PRIORITY
    enum: GL_TEXTURE_RESIDENT
    enum: GL_TEXTURE_BINDING_1D
    enum: GL_TEXTURE_BINDING_2D

    enum: GL_VERTEX_ARRAY
    enum: GL_NORMAL_ARRAY
    enum: GL_COLOR_ARRAY
    enum: GL_INDEX_ARRAY
    enum: GL_TEXTURE_COORD_ARRAY
    enum: GL_EDGE_FLAG_ARRAY
    enum: GL_VERTEX_ARRAY_SIZE
    enum: GL_VERTEX_ARRAY_TYPE
    enum: GL_VERTEX_ARRAY_STRIDE
    enum: GL_NORMAL_ARRAY_TYPE
    enum: GL_NORMAL_ARRAY_STRIDE
    enum: GL_COLOR_ARRAY_SIZE
    enum: GL_COLOR_ARRAY_TYPE
    enum: GL_COLOR_ARRAY_STRIDE
    enum: GL_INDEX_ARRAY_TYPE
    enum: GL_INDEX_ARRAY_STRIDE
    enum: GL_TEXTURE_COORD_ARRAY_SIZE
    enum: GL_TEXTURE_COORD_ARRAY_TYPE
    enum: GL_TEXTURE_COORD_ARRAY_STRIDE
    enum: GL_EDGE_FLAG_ARRAY_STRIDE
    enum: GL_VERTEX_ARRAY_POINTER
    enum: GL_NORMAL_ARRAY_POINTER
    enum: GL_COLOR_ARRAY_POINTER
    enum: GL_INDEX_ARRAY_POINTER
    enum: GL_TEXTURE_COORD_ARRAY_POINTER
    enum: GL_EDGE_FLAG_ARRAY_POINTER
    enum: GL_V2F
    enum: GL_V3F
    enum: GL_C4UB_V2F
    enum: GL_C4UB_V3F
    enum: GL_C3F_V3F
    enum: GL_N3F_V3F
    enum: GL_C4F_N3F_V3F
    enum: GL_T2F_V3F
    enum: GL_T4F_V4F
    enum: GL_T2F_C4UB_V3F
    enum: GL_T2F_C3F_V3F
    enum: GL_T2F_N3F_V3F
    enum: GL_T2F_C4F_N3F_V3F
    enum: GL_T4F_C4F_N3F_V4F

    enum: GL_VERTEX_ARRAY_EXT
    enum: GL_NORMAL_ARRAY_EXT
    enum: GL_COLOR_ARRAY_EXT
    enum: GL_INDEX_ARRAY_EXT
    enum: GL_TEXTURE_COORD_ARRAY_EXT
    enum: GL_EDGE_FLAG_ARRAY_EXT
    enum: GL_VERTEX_ARRAY_SIZE_EXT
    enum: GL_VERTEX_ARRAY_TYPE_EXT
    enum: GL_VERTEX_ARRAY_STRIDE_EXT
    enum: GL_VERTEX_ARRAY_COUNT_EXT
    enum: GL_NORMAL_ARRAY_TYPE_EXT
    enum: GL_NORMAL_ARRAY_STRIDE_EXT
    enum: GL_NORMAL_ARRAY_COUNT_EXT
    enum: GL_COLOR_ARRAY_SIZE_EXT
    enum: GL_COLOR_ARRAY_TYPE_EXT
    enum: GL_COLOR_ARRAY_STRIDE_EXT
    enum: GL_COLOR_ARRAY_COUNT_EXT
    enum: GL_INDEX_ARRAY_TYPE_EXT
    enum: GL_INDEX_ARRAY_STRIDE_EXT
    enum: GL_INDEX_ARRAY_COUNT_EXT
    enum: GL_TEXTURE_COORD_ARRAY_SIZE_EXT
    enum: GL_TEXTURE_COORD_ARRAY_TYPE_EXT
    enum: GL_TEXTURE_COORD_ARRAY_STRIDE_EXT
    enum: GL_TEXTURE_COORD_ARRAY_COUNT_EXT
    enum: GL_EDGE_FLAG_ARRAY_STRIDE_EXT
    enum: GL_EDGE_FLAG_ARRAY_COUNT_EXT
    enum: GL_VERTEX_ARRAY_POINTER_EXT
    enum: GL_NORMAL_ARRAY_POINTER_EXT
    enum: GL_COLOR_ARRAY_POINTER_EXT
    enum: GL_INDEX_ARRAY_POINTER_EXT
    enum: GL_TEXTURE_COORD_ARRAY_POINTER_EXT
    enum: GL_EDGE_FLAG_ARRAY_POINTER_EXT
    enum: GL_DOUBLE_EXT

    enum: GL_BGR_EXT
    enum: GL_BGRA_EXT

    enum: GL_COLOR_TABLE_FORMAT_EXT
    enum: GL_COLOR_TABLE_WIDTH_EXT
    enum: GL_COLOR_TABLE_RED_SIZE_EXT
    enum: GL_COLOR_TABLE_GREEN_SIZE_EXT
    enum: GL_COLOR_TABLE_BLUE_SIZE_EXT
    enum: GL_COLOR_TABLE_ALPHA_SIZE_EXT
    enum: GL_COLOR_TABLE_LUMINANCE_SIZE_EXT
    enum: GL_COLOR_TABLE_INTENSITY_SIZE_EXT

    enum: GL_COLOR_INDEX1_EXT
    enum: GL_COLOR_INDEX2_EXT
    enum: GL_COLOR_INDEX4_EXT
    enum: GL_COLOR_INDEX8_EXT
    enum: GL_COLOR_INDEX12_EXT
    enum: GL_COLOR_INDEX16_EXT

    enum: GL_MAX_ELEMENTS_VERTICES_WIN
    enum: GL_MAX_ELEMENTS_INDICES_WIN

    enum: GL_PHONG_WIN
    enum: GL_PHONG_HINT_WIN

    enum: GL_FOG_SPECULAR_TEXTURE_WIN

    enum: GL_LOGIC_OP
    enum: GL_TEXTURE_COMPONENTS

    void glAccum (GLenum op, GLfloat value)
    void glAlphaFunc (GLenum func, GLclampf ref)
    GLboolean glAreTexturesResident (GLsizei n, const GLuint *textures, GLboolean *residences)
    void glArrayElement (GLint i)
    void glBegin (GLenum mode)
    void glBindTexture (GLenum target, GLuint texture)
    void glBitmap (GLsizei width, GLsizei height, GLfloat xorig, GLfloat yorig, GLfloat xmove, GLfloat ymove, const GLubyte *bitmap)
    void glBlendFunc (GLenum sfactor, GLenum dfactor)
    void glCallList (GLuint list)
    void glCallLists (GLsizei n, GLenum type, const GLvoid *lists)
    void glClear (GLbitfield mask)
    void glClearAccum (GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha)
    void glClearColor (GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha)
    void glClearDepth (GLclampd depth)
    void glClearIndex (GLfloat c)
    void glClearStencil (GLint s)
    void glClipPlane (GLenum plane, const GLdouble *equation)
    void glColor3b (GLbyte red, GLbyte green, GLbyte blue)
    void glColor3bv (const GLbyte *v)
    void glColor3d (GLdouble red, GLdouble green, GLdouble blue)
    void glColor3dv (const GLdouble *v)
    void glColor3f (GLfloat red, GLfloat green, GLfloat blue)
    void glColor3fv (const GLfloat *v)
    void glColor3i (GLint red, GLint green, GLint blue)
    void glColor3iv (const GLint *v)
    void glColor3s (GLshort red, GLshort green, GLshort blue)
    void glColor3sv (const GLshort *v)
    void glColor3ub (GLubyte red, GLubyte green, GLubyte blue)
    void glColor3ubv (const GLubyte *v)
    void glColor3ui (GLuint red, GLuint green, GLuint blue)
    void glColor3uiv (const GLuint *v)
    void glColor3us (GLushort red, GLushort green, GLushort blue)
    void glColor3usv (const GLushort *v)
    void glColor4b (GLbyte red, GLbyte green, GLbyte blue, GLbyte alpha)
    void glColor4bv (const GLbyte *v)
    void glColor4d (GLdouble red, GLdouble green, GLdouble blue, GLdouble alpha)
    void glColor4dv (const GLdouble *v)
    void glColor4f (GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha)
    void glColor4fv (const GLfloat *v)
    void glColor4i (GLint red, GLint green, GLint blue, GLint alpha)
    void glColor4iv (const GLint *v)
    void glColor4s (GLshort red, GLshort green, GLshort blue, GLshort alpha)
    void glColor4sv (const GLshort *v)
    void glColor4ub (GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha)
    void glColor4ubv (const GLubyte *v)
    void glColor4ui (GLuint red, GLuint green, GLuint blue, GLuint alpha)
    void glColor4uiv (const GLuint *v)
    void glColor4us (GLushort red, GLushort green, GLushort blue, GLushort alpha)
    void glColor4usv (const GLushort *v)
    void glColorMask (GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha)
    void glColorMaterial (GLenum face, GLenum mode)
    void glColorPointer (GLint size, GLenum type, GLsizei stride, const GLvoid *pointer)
    void glCopyPixels (GLint x, GLint y, GLsizei width, GLsizei height, GLenum type)
    void glCopyTexImage1D (GLenum target, GLint level, GLenum internalFormat, GLint x, GLint y, GLsizei width, GLint border)
    void glCopyTexImage2D (GLenum target, GLint level, GLenum internalFormat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border)
    void glCopyTexSubImage1D (GLenum target, GLint level, GLint xoffset, GLint x, GLint y, GLsizei width)
    void glCopyTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height)
    void glCullFace (GLenum mode)
    void glDeleteLists (GLuint list, GLsizei range)
    void glDeleteTextures (GLsizei n, const GLuint *textures)
    void glDepthFunc (GLenum func)
    void glDepthMask (GLboolean flag)
    void glDepthRange (GLclampd zNear, GLclampd zFar)
    void glDisable (GLenum cap)
    void glDisableClientState (GLenum array)
    void glDrawArrays (GLenum mode, GLint first, GLsizei count)
    void glDrawBuffer (GLenum mode)
    void glDrawElements (GLenum mode, GLsizei count, GLenum type, const GLvoid *indices)
    void glDrawPixels (GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *pixels)
    void glEdgeFlag (GLboolean flag)
    void glEdgeFlagPointer (GLsizei stride, const GLvoid *pointer)
    void glEdgeFlagv (const GLboolean *flag)
    void glEnable (GLenum cap)
    void glEnableClientState (GLenum array)
    void glEnd ()
    void glEndList ()
    void glEvalCoord1d (GLdouble u)
    void glEvalCoord1dv (const GLdouble *u)
    void glEvalCoord1f (GLfloat u)
    void glEvalCoord1fv (const GLfloat *u)
    void glEvalCoord2d (GLdouble u, GLdouble v)
    void glEvalCoord2dv (const GLdouble *u)
    void glEvalCoord2f (GLfloat u, GLfloat v)
    void glEvalCoord2fv (const GLfloat *u)
    void glEvalMesh1 (GLenum mode, GLint i1, GLint i2)
    void glEvalMesh2 (GLenum mode, GLint i1, GLint i2, GLint j1, GLint j2)
    void glEvalPoint1 (GLint i)
    void glEvalPoint2 (GLint i, GLint j)
    void glFeedbackBuffer (GLsizei size, GLenum type, GLfloat *buffer)
    void glFinish ()
    void glFlush ()
    void glFogf (GLenum pname, GLfloat param)
    void glFogfv (GLenum pname, const GLfloat *params)
    void glFogi (GLenum pname, GLint param)
    void glFogiv (GLenum pname, const GLint *params)
    void glFrontFace (GLenum mode)
    void glFrustum (GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar)
    GLuint glGenLists (GLsizei range)
    void glGenTextures (GLsizei n, GLuint *textures)
    void glGetBooleanv (GLenum pname, GLboolean *params)
    void glGetClipPlane (GLenum plane, GLdouble *equation)
    void glGetDoublev (GLenum pname, GLdouble *params)
    GLenum glGetError ()
    void glGetFloatv (GLenum pname, GLfloat *params)
    void glGetIntegerv (GLenum pname, GLint *params)
    void glGetLightfv (GLenum light, GLenum pname, GLfloat *params)
    void glGetLightiv (GLenum light, GLenum pname, GLint *params)
    void glGetMapdv (GLenum target, GLenum query, GLdouble *v)
    void glGetMapfv (GLenum target, GLenum query, GLfloat *v)
    void glGetMapiv (GLenum target, GLenum query, GLint *v)
    void glGetMaterialfv (GLenum face, GLenum pname, GLfloat *params)
    void glGetMaterialiv (GLenum face, GLenum pname, GLint *params)
    void glGetPixelMapfv (GLenum map, GLfloat *values)
    void glGetPixelMapuiv (GLenum map, GLuint *values)
    void glGetPixelMapusv (GLenum map, GLushort *values)
    void glGetPointerv (GLenum pname, GLvoid* *params)
    void glGetPolygonStipple (GLubyte *mask)
    const GLubyte * glGetString (GLenum name)
    void glGetTexEnvfv (GLenum target, GLenum pname, GLfloat *params)
    void glGetTexEnviv (GLenum target, GLenum pname, GLint *params)
    void glGetTexGendv (GLenum coord, GLenum pname, GLdouble *params)
    void glGetTexGenfv (GLenum coord, GLenum pname, GLfloat *params)
    void glGetTexGeniv (GLenum coord, GLenum pname, GLint *params)
    void glGetTexImage (GLenum target, GLint level, GLenum format, GLenum type, GLvoid *pixels)
    void glGetTexLevelParameterfv (GLenum target, GLint level, GLenum pname, GLfloat *params)
    void glGetTexLevelParameteriv (GLenum target, GLint level, GLenum pname, GLint *params)
    void glGetTexParameterfv (GLenum target, GLenum pname, GLfloat *params)
    void glGetTexParameteriv (GLenum target, GLenum pname, GLint *params)
    void glHint (GLenum target, GLenum mode)
    void glIndexMask (GLuint mask)
    void glIndexPointer (GLenum type, GLsizei stride, const GLvoid *pointer)
    void glIndexd (GLdouble c)
    void glIndexdv (const GLdouble *c)
    void glIndexf (GLfloat c)
    void glIndexfv (const GLfloat *c)
    void glIndexi (GLint c)
    void glIndexiv (const GLint *c)
    void glIndexs (GLshort c)
    void glIndexsv (const GLshort *c)
    void glIndexub (GLubyte c)
    void glIndexubv (const GLubyte *c)
    void glInitNames ()
    void glInterleavedArrays (GLenum format, GLsizei stride, const GLvoid *pointer)
    GLboolean glIsEnabled (GLenum cap)
    GLboolean glIsList (GLuint list)
    GLboolean glIsTexture (GLuint texture)
    void glLightModelf (GLenum pname, GLfloat param)
    void glLightModelfv (GLenum pname, const GLfloat *params)
    void glLightModeli (GLenum pname, GLint param)
    void glLightModeliv (GLenum pname, const GLint *params)
    void glLightf (GLenum light, GLenum pname, GLfloat param)
    void glLightfv (GLenum light, GLenum pname, const GLfloat *params)
    void glLighti (GLenum light, GLenum pname, GLint param)
    void glLightiv (GLenum light, GLenum pname, const GLint *params)
    void glLineStipple (GLint factor, GLushort pattern)
    void glLineWidth (GLfloat width)
    void glListBase (GLuint base)
    void glLoadIdentity ()
    void glLoadMatrixd (const GLdouble *m)
    void glLoadMatrixf (const GLfloat *m)
    void glLoadName (GLuint name)
    void glLogicOp (GLenum opcode)
    void glMap1d (GLenum target, GLdouble u1, GLdouble u2, GLint stride, GLint order, const GLdouble *points)
    void glMap1f (GLenum target, GLfloat u1, GLfloat u2, GLint stride, GLint order, const GLfloat *points)
    void glMap2d (GLenum target, GLdouble u1, GLdouble u2, GLint ustride, GLint uorder, GLdouble v1, GLdouble v2, GLint vstride, GLint vorder, const GLdouble *points)
    void glMap2f (GLenum target, GLfloat u1, GLfloat u2, GLint ustride, GLint uorder, GLfloat v1, GLfloat v2, GLint vstride, GLint vorder, const GLfloat *points)
    void glMapGrid1d (GLint un, GLdouble u1, GLdouble u2)
    void glMapGrid1f (GLint un, GLfloat u1, GLfloat u2)
    void glMapGrid2d (GLint un, GLdouble u1, GLdouble u2, GLint vn, GLdouble v1, GLdouble v2)
    void glMapGrid2f (GLint un, GLfloat u1, GLfloat u2, GLint vn, GLfloat v1, GLfloat v2)
    void glMaterialf (GLenum face, GLenum pname, GLfloat param)
    void glMaterialfv (GLenum face, GLenum pname, const GLfloat *params)
    void glMateriali (GLenum face, GLenum pname, GLint param)
    void glMaterialiv (GLenum face, GLenum pname, const GLint *params)
    void glMatrixMode (GLenum mode)
    void glMultMatrixd (const GLdouble *m)
    void glMultMatrixf (const GLfloat *m)
    void glNewList (GLuint list, GLenum mode)
    void glNormal3b (GLbyte nx, GLbyte ny, GLbyte nz)
    void glNormal3bv (const GLbyte *v)
    void glNormal3d (GLdouble nx, GLdouble ny, GLdouble nz)
    void glNormal3dv (const GLdouble *v)
    void glNormal3f (GLfloat nx, GLfloat ny, GLfloat nz)
    void glNormal3fv (const GLfloat *v)
    void glNormal3i (GLint nx, GLint ny, GLint nz)
    void glNormal3iv (const GLint *v)
    void glNormal3s (GLshort nx, GLshort ny, GLshort nz)
    void glNormal3sv (const GLshort *v)
    void glNormalPointer (GLenum type, GLsizei stride, const GLvoid *pointer)
    void glOrtho (GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar)
    void glPassThrough (GLfloat token)
    void glPixelMapfv (GLenum map, GLsizei mapsize, const GLfloat *values)
    void glPixelMapuiv (GLenum map, GLsizei mapsize, const GLuint *values)
    void glPixelMapusv (GLenum map, GLsizei mapsize, const GLushort *values)
    void glPixelStoref (GLenum pname, GLfloat param)
    void glPixelStorei (GLenum pname, GLint param)
    void glPixelTransferf (GLenum pname, GLfloat param)
    void glPixelTransferi (GLenum pname, GLint param)
    void glPixelZoom (GLfloat xfactor, GLfloat yfactor)
    void glPointSize (GLfloat size)
    void glPolygonMode (GLenum face, GLenum mode)
    void glPolygonOffset (GLfloat factor, GLfloat units)
    void glPolygonStipple (const GLubyte *mask)
    void glPopAttrib ()
    void glPopClientAttrib ()
    void glPopMatrix ()
    void glPopName ()
    void glPrioritizeTextures (GLsizei n, const GLuint *textures, const GLclampf *priorities)
    void glPushAttrib (GLbitfield mask)
    void glPushClientAttrib (GLbitfield mask)
    void glPushMatrix ()
    void glPushName (GLuint name)
    void glRasterPos2d (GLdouble x, GLdouble y)
    void glRasterPos2dv (const GLdouble *v)
    void glRasterPos2f (GLfloat x, GLfloat y)
    void glRasterPos2fv (const GLfloat *v)
    void glRasterPos2i (GLint x, GLint y)
    void glRasterPos2iv (const GLint *v)
    void glRasterPos2s (GLshort x, GLshort y)
    void glRasterPos2sv (const GLshort *v)
    void glRasterPos3d (GLdouble x, GLdouble y, GLdouble z)
    void glRasterPos3dv (const GLdouble *v)
    void glRasterPos3f (GLfloat x, GLfloat y, GLfloat z)
    void glRasterPos3fv (const GLfloat *v)
    void glRasterPos3i (GLint x, GLint y, GLint z)
    void glRasterPos3iv (const GLint *v)
    void glRasterPos3s (GLshort x, GLshort y, GLshort z)
    void glRasterPos3sv (const GLshort *v)
    void glRasterPos4d (GLdouble x, GLdouble y, GLdouble z, GLdouble w)
    void glRasterPos4dv (const GLdouble *v)
    void glRasterPos4f (GLfloat x, GLfloat y, GLfloat z, GLfloat w)
    void glRasterPos4fv (const GLfloat *v)
    void glRasterPos4i (GLint x, GLint y, GLint z, GLint w)
    void glRasterPos4iv (const GLint *v)
    void glRasterPos4s (GLshort x, GLshort y, GLshort z, GLshort w)
    void glRasterPos4sv (const GLshort *v)
    void glReadBuffer (GLenum mode)
    void glReadPixels (GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels)
    void glRectd (GLdouble x1, GLdouble y1, GLdouble x2, GLdouble y2)
    void glRectdv (const GLdouble *v1, const GLdouble *v2)
    void glRectf (GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2)
    void glRectfv (const GLfloat *v1, const GLfloat *v2)
    void glRecti (GLint x1, GLint y1, GLint x2, GLint y2)
    void glRectiv (const GLint *v1, const GLint *v2)
    void glRects (GLshort x1, GLshort y1, GLshort x2, GLshort y2)
    void glRectsv (const GLshort *v1, const GLshort *v2)
    GLint glRenderMode (GLenum mode)
    void glRotated (GLdouble angle, GLdouble x, GLdouble y, GLdouble z)
    void glRotatef (GLfloat angle, GLfloat x, GLfloat y, GLfloat z)
    void glScaled (GLdouble x, GLdouble y, GLdouble z)
    void glScalef (GLfloat x, GLfloat y, GLfloat z)
    void glScissor (GLint x, GLint y, GLsizei width, GLsizei height)
    void glSelectBuffer (GLsizei size, GLuint *buffer)
    void glShadeModel (GLenum mode)
    void glStencilFunc (GLenum func, GLint ref, GLuint mask)
    void glStencilMask (GLuint mask)
    void glStencilOp (GLenum fail, GLenum zfail, GLenum zpass)
    void glTexCoord1d (GLdouble s)
    void glTexCoord1dv (const GLdouble *v)
    void glTexCoord1f (GLfloat s)
    void glTexCoord1fv (const GLfloat *v)
    void glTexCoord1i (GLint s)
    void glTexCoord1iv (const GLint *v)
    void glTexCoord1s (GLshort s)
    void glTexCoord1sv (const GLshort *v)
    void glTexCoord2d (GLdouble s, GLdouble t)
    void glTexCoord2dv (const GLdouble *v)
    void glTexCoord2f (GLfloat s, GLfloat t)
    void glTexCoord2fv (const GLfloat *v)
    void glTexCoord2i (GLint s, GLint t)
    void glTexCoord2iv (const GLint *v)
    void glTexCoord2s (GLshort s, GLshort t)
    void glTexCoord2sv (const GLshort *v)
    void glTexCoord3d (GLdouble s, GLdouble t, GLdouble r)
    void glTexCoord3dv (const GLdouble *v)
    void glTexCoord3f (GLfloat s, GLfloat t, GLfloat r)
    void glTexCoord3fv (const GLfloat *v)
    void glTexCoord3i (GLint s, GLint t, GLint r)
    void glTexCoord3iv (const GLint *v)
    void glTexCoord3s (GLshort s, GLshort t, GLshort r)
    void glTexCoord3sv (const GLshort *v)
    void glTexCoord4d (GLdouble s, GLdouble t, GLdouble r, GLdouble q)
    void glTexCoord4dv (const GLdouble *v)
    void glTexCoord4f (GLfloat s, GLfloat t, GLfloat r, GLfloat q)
    void glTexCoord4fv (const GLfloat *v)
    void glTexCoord4i (GLint s, GLint t, GLint r, GLint q)
    void glTexCoord4iv (const GLint *v)
    void glTexCoord4s (GLshort s, GLshort t, GLshort r, GLshort q)
    void glTexCoord4sv (const GLshort *v)
    void glTexCoordPointer (GLint size, GLenum type, GLsizei stride, const GLvoid *pointer)
    void glTexEnvf (GLenum target, GLenum pname, GLfloat param)
    void glTexEnvfv (GLenum target, GLenum pname, const GLfloat *params)
    void glTexEnvi (GLenum target, GLenum pname, GLint param)
    void glTexEnviv (GLenum target, GLenum pname, const GLint *params)
    void glTexGend (GLenum coord, GLenum pname, GLdouble param)
    void glTexGendv (GLenum coord, GLenum pname, const GLdouble *params)
    void glTexGenf (GLenum coord, GLenum pname, GLfloat param)
    void glTexGenfv (GLenum coord, GLenum pname, const GLfloat *params)
    void glTexGeni (GLenum coord, GLenum pname, GLint param)
    void glTexGeniv (GLenum coord, GLenum pname, const GLint *params)
    void glTexImage1D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLint border, GLenum format, GLenum type, const GLvoid *pixels)
    void glTexImage2D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid *pixels)
    void glTexParameterf (GLenum target, GLenum pname, GLfloat param)
    void glTexParameterfv (GLenum target, GLenum pname, const GLfloat *params)
    void glTexParameteri (GLenum target, GLenum pname, GLint param)
    void glTexParameteriv (GLenum target, GLenum pname, const GLint *params)
    void glTexSubImage1D (GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum type, const GLvoid *pixels)
    void glTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *pixels)
    void glTranslated (GLdouble x, GLdouble y, GLdouble z)
    void glTranslatef (GLfloat x, GLfloat y, GLfloat z)
    void glVertex2d (GLdouble x, GLdouble y)
    void glVertex2dv (const GLdouble *v)
    void glVertex2f (GLfloat x, GLfloat y)
    void glVertex2fv (const GLfloat *v)
    void glVertex2i (GLint x, GLint y)
    void glVertex2iv (const GLint *v)
    void glVertex2s (GLshort x, GLshort y)
    void glVertex2sv (const GLshort *v)
    void glVertex3d (GLdouble x, GLdouble y, GLdouble z)
    void glVertex3dv (const GLdouble *v)
    void glVertex3f (GLfloat x, GLfloat y, GLfloat z)
    void glVertex3fv (const GLfloat *v)
    void glVertex3i (GLint x, GLint y, GLint z)
    void glVertex3iv (const GLint *v)
    void glVertex3s (GLshort x, GLshort y, GLshort z)
    void glVertex3sv (const GLshort *v)
    void glVertex4d (GLdouble x, GLdouble y, GLdouble z, GLdouble w)
    void glVertex4dv (const GLdouble *v)
    void glVertex4f (GLfloat x, GLfloat y, GLfloat z, GLfloat w)
    void glVertex4fv (const GLfloat *v)
    void glVertex4i (GLint x, GLint y, GLint z, GLint w)
    void glVertex4iv (const GLint *v)
    void glVertex4s (GLshort x, GLshort y, GLshort z, GLshort w)
    void glVertex4sv (const GLshort *v)
    void glVertexPointer (GLint size, GLenum type, GLsizei stride, const GLvoid *pointer)
    void glViewport (GLint x, GLint y, GLsizei width, GLsizei height)

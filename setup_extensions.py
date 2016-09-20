#!python3

import sys
from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

glew_dir    = "/usr/include/GL"
sdl_dir     = "/usr/include/SDL2"
opengl_lib  = "GL"
glew_lib    = "GLEW"
sdl_lib     = "SDL2"
sdlmain_lib = "SDL2main"
sdltest_lib = "SDL2_test"

if sys.platform == "win32":
    glew_dir    = "extern/glew-2.0.0/include"
    sdl_dir     = "extern/SDL2-2.0.4/include"
    opengl_lib  = "opengl32"
    
    if sys.maxsize > 0x7fffffff: # 64-bit libraries
        glew_lib    = "extern/glew-2.0.0/lib/Release/x64/glew32"
        sdl_lib     = "extern/SDL2-2.0.4/lib/x64/SDL2"
        sdlmain_lib = "extern/SDL2-2.0.4/lib/x64/SDL2main"
        sdltest_lib = "extern/SDL2-2.0.4/lib/x64/SDL2test"
    else:
        glew_lib    = "extern/glew-2.0.0/lib/Release/Win32/glew32"
        sdl_lib     = "extern/SDL2-2.0.4/lib/x86/SDL2"
        sdlmain_lib = "extern/SDL2-2.0.4/lib/x86/SDL2main"
        sdltest_lib = "extern/SDL2-2.0.4/lib/x86/SDL2test"

setup (
    name = 'PyDoom rendering module',
    ext_modules = cythonize (
        [
            Extension (
                "pydoom.extensions.video",
                ["pydoom/extensions/video.pyx", "pydoom/extensions/cvideo.c"],
                include_dirs = [
                    glew_dir,
                    sdl_dir,
                    ],
                libraries = [
                    opengl_lib,
                    glew_lib,
                    sdl_lib,
                    sdlmain_lib,
                    sdltest_lib,
                    ]
                ),
        
            Extension (
                "pydoom.extensions.utility",
                ["pydoom/extensions/utility.pyx", "pydoom/extensions/cutility.c"],
                include_dirs = [
                    sdl_dir
                    ],
                libraries = [
                    sdl_lib,
                    sdlmain_lib,
                    sdltest_lib,
                    ]
                )
            ]
        )
    )

#!python3

import sys
from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

glew_dir = "/usr/include/GL"
sdl_dir  = "/usr/include/SDL2"
if sys.platform == "win32":
    glew_dir = "extern\\glew-2.0.0\\include"
    sdl_dir  = "extern\\SDL2-2.0.4\\include"

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
                    "GL",
                    "GLEW",
                    "SDL2",
                    "SDL2main",
                    "SDL2_test",
                    ]
                ),
        
            Extension (
                "pydoom.extensions.utility",
                ["pydoom/extensions/utility.pyx", "pydoom/extensions/cutility.c"],
                include_dirs = [
                    sdl_dir
                    ],
                libraries = [
                    "SDL2",
                    "SDL2main",
                    "SDL2_test",
                    ]
                )
            ]
        )
    )

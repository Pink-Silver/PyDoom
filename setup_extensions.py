#!python3

from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

setup (
    name = 'PyDoom rendering module',
    ext_modules = cythonize (
        [
            Extension (
                "pydoom.extensions.video",
                ["pydoom/extensions/video.pyx", "pydoom/extensions/cvideo.c"],
                include_dirs = [
                    "extern\\glew-2.0.0\\include",
                    "extern\\SDL2-2.0.4\\include",
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
                    "extern\\SDL2-2.0.4\\include"
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

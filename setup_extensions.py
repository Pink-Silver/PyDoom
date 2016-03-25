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
                    "extern/glew-1.11.0/include",
                    "extern/SDL2-2.0.3/include",
                    ],
                libraries = [
                    "GL",
                    "extern/glew-1.11.0/lib/Release/x64/glew32",
                    "extern/SDL2-2.0.3/lib/x64/SDL2",
                    "extern/SDL2-2.0.3/lib/x64/SDL2main",
                    "extern/SDL2-2.0.3/lib/x64/SDL2test",
                    ]
                ),
        
            Extension (
                "pydoom.extensions.utility",
                ["pydoom/extensions/utility.pyx", "pydoom/extensions/cutility.c"],
                include_dirs = [
                    "extern/SDL2-2.0.3/include"
                    ],
                libraries = [
                    "extern/SDL2-2.0.3/lib/x64/SDL2",
                    "extern/SDL2-2.0.3/lib/x64/SDL2main",
                    "extern/SDL2-2.0.3/lib/x64/SDL2test",
                    ]
                )
            ]
        )
    )

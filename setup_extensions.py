#!python3

from distutils.core import setup
from Cython.Build import cythonize

setup (
    name = 'PyDoom rendering module',
    ext_modules = cythonize ("extsrc/video.pyx"),
    )

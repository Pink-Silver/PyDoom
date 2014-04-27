from distutils.core import setup, Extension

gl2drender = Extension('gl2d_renderer',
                       sources = ['gl2d_src/gl2d_renderer.cpp'])

setup (ext_modules = [gl2drender])

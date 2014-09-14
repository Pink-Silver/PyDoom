// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

#ifndef GLOBAL_HPP
#define GLOBAL_HPP

#ifdef _MSC_VER
    #pragma warning(disable: 4996) // blah blah "sprintf is unsafe USE OUR WINDOWS-SPECIFIC FUNCTIONS INSTEAD"
#endif

// Strings
#include <string>

// Exceptions used in various places
#include <exception>
#include <stdexcept>

// Python
#define PY_SSIZE_T_CLEAN
#include <Python.h>

// Modules
extern "C"
{
    PyMODINIT_FUNC PyInit_arguments ();
    PyMODINIT_FUNC PyInit_configuration ();
    PyMODINIT_FUNC PyInit_games ();
    PyMODINIT_FUNC PyInit_graphics ();
    PyMODINIT_FUNC PyInit_resources ();
    PyMODINIT_FUNC PyInit_utility ();
    PyMODINIT_FUNC PyInit_version ();
    PyMODINIT_FUNC PyInit_video ();
}

// Math
#include <cmath>

// Windows-specific stuff
#ifdef WIN32
#include <Windows.h>
#endif

// SDL & OpenGL
#include <SDL.h>
#include <GL/glew.h>

#endif // __GLOBAL_HPP__

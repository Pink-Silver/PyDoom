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

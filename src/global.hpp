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

// Exceptions used in various places
#include <exception>
#include <stdexcept>

class PyDoom_NoBufferError: public std::exception {};
class PyDoom_MemoryError: public std::exception {};

// Python
#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include "py_cpp.hpp"

// Math
#include <cmath>

// SDL
#include "SDL.h"

// OpenGL
#ifdef WIN32
//#pragma warning( disable : 4507 34 )
#include <Windows.h>
#endif
#include <gl/gl.h>

#endif // __GLOBAL_HPP__

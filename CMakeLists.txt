# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

##################################################
##           PyDoom CMake Build File            ##
##################################################

cmake_minimum_required (VERSION 2.8)
project (PyDoom C CXX)

# Version information
set (Python_ADDITIONAL_VERSIONS "3.4")

# Dependencies
find_package (Git)
find_package (PythonLibs   REQUIRED)
find_package (PythonInterp REQUIRED)
find_package (OpenGL       REQUIRED)
find_package (SDL          REQUIRED)

# Tagging
file (REMOVE "${PyDoom_SOURCE_DIR}/src/version.pyx")
set (PyDoom_GIT_VERSION "unknown")

if (GIT_FOUND)
    execute_process (COMMAND ${GIT_EXECUTABLE} "describe" "--tags"
        OUTPUT_STRIP_TRAILING_WHITESPACE
        WORKING_DIRECTORY "${PyDoom_SOURCE_DIR}"
        OUTPUT_VARIABLE PyDoom_GIT_VERSION
        )
endif ()

configure_file (
    "${PyDoom_SOURCE_DIR}/src/version.in.pyx"
    "${PyDoom_SOURCE_DIR}/src/version.pyx"
    )

# Building
add_subdirectory (src)

# Program zip
add_custom_target (PyDoomResource.zip ALL
    ${PYTHON_EXECUTABLE} "${PyDoom_SOURCE_DIR}/MakeZip.py"
    "${PyDoom_SOURCE_DIR}/resourcezip" "${PyDoom_BINARY_DIR}/PyDoomResource.zip")
install (FILES "${PyDoom_BINARY_DIR}/PyDoomResource.zip"
    DESTINATION ${CMAKE_INSTALL_PREFIX})

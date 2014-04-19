##################################################
##           PyDoom CMake Build File            ##
## This file is under the 3-clause BSD license. ##
## See LICENSE for more information.            ##
##################################################

cmake_minimum_required (VERSION 2.8)
project (PyDoom)

# Version information
set (PyDoom_VERSION_MAJOR 1)
set (PyDoom_VERSION_MINOR 0)

# Dependencies
#   Python
set (Python_ADDITIONAL_VERSIONS "3.4")
find_package (PythonLibs)
find_package (PythonInterp)
if (!PYTHONLIBS_FOUND)
    message (FATAL_ERROR "A Python installation is required to compile PyDoom, but was not found.")
endif ()
if (!PYTHONINTERP_FOUND)
    message (FATAL_ERROR "A Python installation is required to compile PyDoom, but was not found.")
endif ()
include_directories ("${PYTHON_INCLUDE_DIRS}")

# Source
add_executable (PyDoom "src/main.cpp")
target_link_libraries (PyDoom "${PYTHON_LIBRARIES}")

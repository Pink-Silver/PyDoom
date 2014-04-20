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
    message (FATAL_ERROR "Python is required to compile PyDoom.")
endif ()
if (!PYTHONINTERP_FOUND)
    message (FATAL_ERROR "Python is required to compile PyDoom.")
endif ()
include_directories ("${PYTHON_INCLUDE_DIRS}")

# Source
add_executable (PyDoom "src/main.cpp")
target_link_libraries (PyDoom "${PYTHON_LIBRARIES}")

add_custom_command (TARGET PyDoom POST_BUILD
                    COMMAND ${PYTHON_EXECUTABLE}
                        ARGS "./MakeProgramZip.py" "$(OutDir)PyDoom.zip")

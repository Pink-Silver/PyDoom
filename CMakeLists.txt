##################################################
##           PyDoom CMake Build File            ##
## This file is under the 3-clause BSD license. ##
## See LICENSE for more information.            ##
##################################################

cmake_minimum_required (VERSION 2.8)
project (PyDoom)

# Version information
set (Python_ADDITIONAL_VERSIONS "3.4")

# Dependencies
find_package (PythonLibs   REQUIRED)
find_package (PythonInterp REQUIRED)
find_package (OpenGL       REQUIRED)
find_package (SDL          REQUIRED)

# Building
include_directories ("${PYTHON_INCLUDE_DIRS}" "${SDL_INCLUDE_DIR}")
add_executable (PyDoom "src/main.cpp")
target_link_libraries (PyDoom "${PYTHON_LIBRARIES}" "${SDL_LIBRARY}" "${SDLMAIN_LIBRARY}")

# Program zip
add_custom_target (PyDoom.zip ALL ${PYTHON_EXECUTABLE} "MakeProgramZip.py"
    "$<TARGET_FILE_DIR:PyDoom>")

# C-Python extensions
add_custom_target (DistUtils ALL ${PYTHON_EXECUTABLE} "distutils_setup.py"
    "build_ext" "--build-lib" "$<TARGET_FILE_DIR:PyDoom>")

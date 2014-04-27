##################################################
##           PyDoom CMake Build File            ##
## This file is under the 3-clause BSD license. ##
## See LICENSE for more information.            ##
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
file (REMOVE "${PyDoom_SOURCE_DIR}/pysrc/version.py")
set (PyDoom_GIT_VERSION "unknown")

if (GIT_FOUND)
    execute_process (COMMAND ${GIT_EXECUTABLE} "describe" "--tags"
        OUTPUT_STRIP_TRAILING_WHITESPACE
        WORKING_DIRECTORY "${PyDoom_SOURCE_DIR}"
        OUTPUT_VARIABLE PyDoom_GIT_VERSION
        )
endif ()

configure_file (
    "${PyDoom_SOURCE_DIR}/src/version.in.py"
    "${PyDoom_SOURCE_DIR}/pysrc/version.py"
    )

# Building
add_subdirectory (src)
add_subdirectory (columnrender_src)

# Program zip
add_custom_target (PyDoom.zip ALL
    ${PYTHON_EXECUTABLE} "${PyDoom_SOURCE_DIR}/MakeProgramZip.py"
    "${PyDoom_SOURCE_DIR}/pysrc" "${PyDoom_BINARY_DIR}")
install (FILES "${PyDoom_BINARY_DIR}/PyDoom.zip" DESTINATION ${CMAKE_INSTALL_PREFIX})

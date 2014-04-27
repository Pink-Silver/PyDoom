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
file (REMOVE "${PyDoom_SOURCE_DIR}/pysrc/pydoom_version.py")
set (PyDoom_GIT_VERSION "unknown")

if (GIT_FOUND)
    execute_process (COMMAND ${GIT_EXECUTABLE} "describe" "--tags"
        OUTPUT_STRIP_TRAILING_WHITESPACE
        WORKING_DIRECTORY "${PyDoom_SOURCE_DIR}"
        OUTPUT_VARIABLE PyDoom_GIT_VERSION
        )
endif ()

configure_file (
    "${PyDoom_SOURCE_DIR}/src/pydoom_version.py.in"
    "${PyDoom_SOURCE_DIR}/pysrc/pydoom_version.py"
    )

# Building
include_directories ("${PYTHON_INCLUDE_DIRS}" "${SDL_INCLUDE_DIR}")
add_executable (PyDoom "src/main.cpp")
target_link_libraries (PyDoom "${PYTHON_LIBRARIES}" "${SDL_LIBRARY}" "${SDLMAIN_LIBRARY}")

# Program zip
add_custom_target (PyDoom.zip ALL
    ${PYTHON_EXECUTABLE} "${PyDoom_SOURCE_DIR}/MakeProgramZip.py"
    "${PyDoom_SOURCE_DIR}/pysrc" "$<TARGET_FILE_DIR:PyDoom>")

# C-Python extensions
configure_file (
    "${PyDoom_SOURCE_DIR}/columnrender_setup.py.in"
    "${PyDoom_BINARY_DIR}/columnrender_setup.py"
    )
add_custom_target (DistUtils ALL
    ${PYTHON_EXECUTABLE} "${PyDoom_BINARY_DIR}/columnrender_setup.py"
    "build_ext" "--build-lib" "$<TARGET_FILE_DIR:PyDoom>")

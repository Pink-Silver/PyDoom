##################################################
##           PyDoom CMake Build File            ##
## This file is under the 3-clause BSD license. ##
## See LICENSE for more information.            ##
##################################################

cmake_minimum_required (VERSION 2.8)
project (PyDoom)

set (Python_ADDITIONAL_VERSIONS "3.4")
find_package (PythonLibs)
find_package (PythonInterp)

add_executable(PyDoom main.cpp)

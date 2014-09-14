from cpython cimport PyObject

cdef extern from "global.hpp":
    PyObject *PyInit_arguments ()
    PyObject *PyInit_configuration ()
    PyObject *PyInit_games ()
    PyObject *PyInit_graphics ()
    PyObject *PyInit_resources ()
    PyObject *PyInit_utility ()
    PyObject *PyInit_version ()
    PyObject *PyInit_video ()

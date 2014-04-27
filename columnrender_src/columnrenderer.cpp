// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

#include <Python.h>

static PyMethodDef rmethods[] = {
    {NULL, NULL, 0, NULL} // Sentinel
};

static struct PyModuleDef rmodule = {
    PyModuleDef_HEAD_INIT,
    "columnrenderer",
    "The 2D column-based renderer for PyDoom",
    -1,
    rmethods
};

PyMODINIT_FUNC PyInit_columnrenderer (void)
{
    PyObject *m;
    
    m = PyModule_Create(&rmodule);
    if (m == NULL)
        return NULL;
    
    return m;
}

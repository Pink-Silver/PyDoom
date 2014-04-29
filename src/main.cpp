// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

// Python
#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <cstdlib>

#include "toplevel.hpp"

int main (int argc, char *argv[])
{
    // Disable user site-packages; we only want the system-wide libraries.
    putenv ("PYTHONNOUSERSITE=1");
    
    PyImport_AppendInittab ("toplevel", PyInit_toplevel);
    
    Py_SetProgramName (L"PyDoom");
    Py_Initialize ();
    
    // Feed command-line arguments to Python
    PyObject *args = PyList_New ((Py_ssize_t)argc);
    for (Py_ssize_t i = 0; i < argc; ++i)
    {
        PyObject *arg = Py_BuildValue ("s", argv[i]);
        PyList_SetItem (args, i, arg);
    }
    
    PySys_SetObject ("argv", args);
    
    // Path alteration
    PyObject *path_list = PySys_GetObject ("path");
    
    if (path_list)
    {
        PyObject *pydoom_zip = PyUnicode_FromString ("PyDoom.zip");
        PyList_Insert (path_list, 0, pydoom_zip);
        Py_DECREF (pydoom_zip);
    }
    
    // Initialize the other underlying subsystems
    InitToplevel ();
    
    // Jump into the main program
    PyRun_SimpleString (
        "import main\n"
        "main.main ()\n"
    );
    
    // Clean up
    QuitToplevel ();
    Py_Exit (0);
    
    return 0;
}

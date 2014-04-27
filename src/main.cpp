// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

// Python
#include <Python.h>

int main (int argc, char *argv[])
{
    Py_SetProgramName (L"PyDoom");
    Py_Initialize ();
    
    // Coerce arguments
    PyObject *args = PyList_New ((Py_ssize_t)argc);
    for (Py_ssize_t i = 0; i < argc; ++i)
    {
        PyObject *arg = Py_BuildValue ("s", argv[i]);
        PyList_SetItem (args, i, arg);
    }
    
    PySys_SetObject ("argv", args);
    
    // Path alteration
#ifdef WIN32
    PySys_SetPath (L";PyDoom.zip");
#else
    PySys_SetPath (L":PyDoom.zip");
#endif
    
    // Jump into the main program
    PyRun_SimpleString (
        "import main\n"
        "main.main ()\n"
    );
    
    Py_Exit (0);
    return 0;
}

// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

#include "global.hpp"
#include "opengl.hpp"

// SDL
#include "SDL.h"

int main (int argc, char *argv[])
{
    // Disable user site-packages; we only want the system-wide libraries.
    putenv ("PYTHONNOUSERSITE=1");
    
    PyImport_AppendInittab ("PyDoom_OpenGL", PyInit_PyDoom_GL);
    
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
    InitFramework ();
    
    // Jump into the main program
    PyRun_SimpleString (
        "import traceback\n"
        "from tkinter import Tk\n"
        "from tkinter.messagebox import showerror\n"
        "import logging\n"
        "from logging import FileHandler\n"

        "interp = Tk ()\n"
        "interp.withdraw ()\n"
        
        "master_log = logging.getLogger (\"PyDoom\")\n"
        "master_log.setLevel (\"INFO\")\n"
        "master_log.addHandler (FileHandler (\"pydoom.log\", \"w\"))\n"

        "try:\n"
        "    import pydoom.main\n"
        "    pydoom.main.main ()\n"
        "except Exception as err:\n"
        "    exctext = traceback.format_exc ()\n"
        "    master_log.error (exctext)\n"
        "    showerror (title=\"PyDoom Error\", parent=interp, message=exctext)\n"
    );
    
    // Clean up
    QuitFramework ();
    Py_Exit (0);
    
    return 0;
}

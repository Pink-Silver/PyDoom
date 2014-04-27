// Python
#include <Python.h>

// SDL
#include "SDL.h"

// OpenGL
#ifdef _MSC_VER
#include <Windows.h>
#endif
#include <gl/gl.h>

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
    PySys_SetPath (L"PyDoom.zip");
    
    // Jump into the main program
    PyRun_SimpleString ("import pydoom_main\npydoom_main.main ()\n");
    
    Py_Exit (0);
    return 0;
}

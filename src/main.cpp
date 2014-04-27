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
    
    PyRun_SimpleString ("\
import sys\n\
sys.path = [\"PyDoom.zip\"] + sys.path\n\
del sys\n\
import pydoom_main\n\
pydoom_main.main ()\n");
    return 0;
}

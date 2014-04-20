// Dummy
#include <Python.h>

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

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
    
    PyImport_AppendInittab ("pydoom.opengl", PyInit_PyDoom_GL);
    
    Py_SetProgramName (L"PyDoom");
    Py_Initialize ();

    int pyargc = 2;
    wchar_t **pyargv = NULL;

    pyargv = (wchar_t **) calloc (pyargc, sizeof (wchar_t *));

    int proglen = strlen (argv[0]) + 1;
    wchar_t *progname = (wchar_t *) calloc (proglen, sizeof (wchar_t));
    mbstowcs (progname, argv[0], proglen);
    wchar_t *zipname = L"PyDoom.zip";
    pyargv[0] = progname;
    pyargv[1] = (wchar_t *) calloc (11, sizeof (wchar_t));
    memcpy (pyargv[1], zipname, 11 * sizeof (wchar_t));

    for (int curarg = 1; curarg < argc; ++curarg)
    {
        int oldstrlen = strlen (argv[curarg]) + 1;
        wchar_t *newstr = (wchar_t *) calloc (oldstrlen, sizeof (wchar_t));
        if (!newstr) continue; // Ran out of memory for this arg
        if (mbstowcs (newstr, argv[curarg], oldstrlen))
        {
            int newindex = pyargc++;
            pyargv = (wchar_t **) realloc (pyargv, sizeof (wchar_t *) * pyargc);

            if (!pyargv)
                return 1; // Ran out of memory

            pyargv[newindex] = newstr;
        }
    }
    
    // Initialize the other underlying subsystems
    InitFramework ();
    
    // Jump into the main program
    int failure = Py_Main (pyargc, pyargv);

    if (failure == 2)
        PySys_WriteStderr ("Bad command line!");
    
    // Clean up
    QuitFramework ();
    Py_Exit (failure == 1? 1 : 0);
    
    return 0;
}

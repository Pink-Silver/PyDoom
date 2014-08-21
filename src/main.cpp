// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

#include "global.hpp"
#include "video.hpp"

wchar_t *GetProgramZip ()
{
    wchar_t *path = (wchar_t *)calloc (1025, sizeof (wchar_t));
    GetModuleFileNameW (NULL, path, 1024);

    int r;
    for (r = 1024; r > 0 && path[r] != L'.'; --r);
    ++r;
    path[r++] = L'z';
    path[r++] = L'i';
    path[r]   = L'p';

    return path;
}

int main (int argc, char *argv[])
{
    PyImport_AppendInittab ("pydoom_video", PyInit_PyDoom_Video);
    
    Py_SetProgramName (L"PyDoom");
    Py_Initialize ();

    int pyargc = 3;
    wchar_t **pyargv = NULL;

    pyargv = (wchar_t **) calloc (pyargc, sizeof (wchar_t *));

    int proglen = strlen (argv[0]) + 1;
    wchar_t *progname = (wchar_t *) calloc (proglen, sizeof (wchar_t));
    mbstowcs (progname, argv[0], proglen);
    wchar_t *zipname = GetProgramZip ();
    pyargv[0] = progname;
    pyargv[1] = L"-I";
    pyargv[2] = (wchar_t *) calloc (1025, sizeof (wchar_t));
    memcpy (pyargv[2], zipname, 1025 * sizeof (wchar_t));

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
    InitVideo ();
    
    //PySys_SetArgv(pyargc - 1, &pyargv[1]);

    // Jump into the main program
    int failure = Py_Main (pyargc, pyargv);

    // Clean up
    QuitVideo ();
    Py_Exit (failure);
    
    return 0;
}

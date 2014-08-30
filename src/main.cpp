// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

#include "global.hpp"
#define DL_IMPORT(n) n
#undef PyMODINIT_FUNC
#define PyMODINIT_FUNC extern "C" PyObject *
#include "video.hpp"

wchar_t *GetProgramZip ()
{
    wchar_t *path = (wchar_t *)calloc (1025, sizeof (wchar_t));
    GetModuleFileNameW (NULL, path, 1024);

    int r;
    for (r = 1024; r > 0 && path[r] != L'\\'; --r);
    ++r;

    if (r > 1014)
        return NULL;

    path[r++] = L'P';
    path[r++] = L'y';
    path[r++] = L'D';
    path[r++] = L'o';
    path[r++] = L'o';
    path[r++] = L'm';
    path[r++] = L'.';
    path[r++] = L'z';
    path[r++] = L'i';
    path[r++] = L'p';
    path[r]   = NULL;

    return path;
}

int main (int argc, char *argv[])
{
    PyImport_AppendInittab ("pydoom_video", PyInit_video);
    
    Py_SetProgramName (L"PyDoom");
    Py_Initialize ();

    int pyargc = 3;
    wchar_t **pyargv = NULL;

    pyargv = (wchar_t **) calloc (pyargc, sizeof (wchar_t *));

    int proglen = strlen (argv[0]) + 1;
    wchar_t *progname = (wchar_t *) calloc (proglen, sizeof (wchar_t));
    mbstowcs (progname, argv[0], proglen);
    wchar_t *zipname = GetProgramZip ();
    if (!zipname) Py_Exit (2);
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
    int err = SDL_Init (SDL_INIT_TIMER | SDL_INIT_EVENTS | SDL_INIT_VIDEO);
    if (err)
        return 1;

    SDL_DisableScreenSaver ();
    
    // Jump into the main program
    int failure = Py_Main (pyargc, pyargv);

    // Clean up
    SDL_Quit ();
    Py_Exit (failure);
    
    return 0;
}

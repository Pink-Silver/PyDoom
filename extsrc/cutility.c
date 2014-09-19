// Copyright (c) 2014, Kate Stone
// All rights reserved.
//
// This file is covered by the 3-clause BSD license.
// See the LICENSE file in this program's distribution for details.

// Python
//#define PY_SSIZE_T_CLEAN
//#include <Python.h>

// SDL
#define SDL_MAIN_HANDLED
#include <SDL.h>

int util_initsdl (void)
{
    int failure;
    SDL_SetMainReady ();
    
    failure = SDL_Init (SDL_INIT_TIMER | SDL_INIT_VIDEO | SDL_INIT_EVENTS);
    if (failure != 0)
        return 1;
    
    return 0;
}

void util_quitsdl (void)
{
    SDL_Quit ();
}

// Timer
double timer_tick (void)
{
    Uint64 start, end;
    start = SDL_GetPerformanceCounter ();
    SDL_Delay (4);
    end = SDL_GetPerformanceCounter ();
    return (double)(end - start) / (double)SDL_GetPerformanceFrequency ();
}

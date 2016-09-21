# Copyright (c) 2014, Kate Fox
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

cdef extern from "main_handled.h":
    # Solely to tell SDL that we're handling the main() function.
    pass

cdef extern from "<SDL.h>":
    ctypedef long long int Uint64
    ctypedef int Uint32
    
    enum:
        SDL_INIT_TIMER
        SDL_INIT_VIDEO
        SDL_INIT_EVENTS
    
    int SDL_Init (Uint32 flags)
    void SDL_Quit ()
    void SDL_Delay (Uint32 ms)
    void SDL_SetMainReady ()
    Uint64 SDL_GetPerformanceCounter ()
    Uint64 SDL_GetPerformanceFrequency()
    const char *SDL_GetError ()
    void SDL_ClearError ()

def initialize ():
    cdef int failure = 0
    cdef const char *err = NULL
    SDL_SetMainReady ()
    
    failure = SDL_Init (SDL_INIT_TIMER | SDL_INIT_VIDEO | SDL_INIT_EVENTS)
    if failure is not 0:
        err = SDL_GetError ()
        SDL_ClearError ()
        raise RuntimeError (str (err, "utf8"))

def shutdown ():
    SDL_Quit ()

# Timer
def tick ():
    cdef Uint64 start = 0
    cdef Uint64 end = 0
    start = SDL_GetPerformanceCounter ()
    SDL_Delay (4)
    end = SDL_GetPerformanceCounter ()
    return <double>(end - start) / <double>SDL_GetPerformanceFrequency ()

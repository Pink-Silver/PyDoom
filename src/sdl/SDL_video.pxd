#  Simple DirectMedia Layer
#  Copyright (C) 1997-2014 Sam Lantinga <slouken@libsdl.org>
#
#  This software is provided 'as-is', without any express or implied
#  warranty.  In no event will the authors be held liable for any damages
#  arising from the use of this software.
#
#  Permission is granted to anyone to use this software for any purpose,
#  including commercial applications, and to alter it and redistribute it
#  freely, subject to the following restrictions:
#
#  1. The origin of this software must not be misrepresented; you must not
#     claim that you wrote the original software. If you use this software
#     in a product, an acknowledgment in the product documentation would be
#     appreciated but is not required.
#  2. Altered source versions must be plainly marked as such, and must not be
#     misrepresented as being the original software.
#  3. This notice may not be removed or altered from any source distribution.

#
# SDL_video.h
#
# Header file for SDL video functions.

#include "SDL_pixels.h"
#include "SDL_rect.h"
#include "SDL_surface.h"

from libc.stdint cimport uint16_t, uint32_t

cdef extern from "SDL_video.h":
    ctypedef struct SDL_DisplayMode:
        uint32_t format  # pixel format
        int w            # width
        int h            # height
        int refresh_rate # refresh rate (or zero for unspecified)
        void *driverdata # driver-specific data, initialize to 0

    cdef struct SDL_Window
    
    enum SDL_WindowFlags:
        SDL_WINDOW_FULLSCREEN       # fullscreen window
        SDL_WINDOW_OPENGL           # window usable with OpenGL context
        SDL_WINDOW_SHOWN            # window is visible
        SDL_WINDOW_HIDDEN           # window is not visible
        SDL_WINDOW_BORDERLESS       # no window decoration
        SDL_WINDOW_RESIZABLE        # window can be resized
        SDL_WINDOW_MINIMIZED        # window is minimized
        SDL_WINDOW_MAXIMIZED        # window is maximized
        SDL_WINDOW_INPUT_GRABBED    # window has grabbed input focus
        SDL_WINDOW_INPUT_FOCUS      # window has input focus
        SDL_WINDOW_MOUSE_FOCUS      # window has mouse focus
        SDL_WINDOW_FULLSCREEN_DESKTOP
        SDL_WINDOW_FOREIGN          # window not created by SDL
        SDL_WINDOW_ALLOW_HIGHDPI    # window should be created in high-DPI mode
                                    # if supported

    int SDL_WINDOWPOS_UNDEFINED_DISPLAY (int x)
    bint SDL_WINDOWPOS_ISUNDEFINED (int x)
    enum: SDL_WINDOWPOS_UNDEFINED

    int SDL_WINDOWPOS_CENTERED_DISPLAY (int x)
    bint SDL_WINDOWPOS_ISCENTERED (int x)
    enum: SDL_WINDOWPOS_CENTERED

    enum SDL_WindowEventID:
        SDL_WINDOWEVENT_NONE            # Never used
        SDL_WINDOWEVENT_SHOWN           # Window has been shown
        SDL_WINDOWEVENT_HIDDEN          # Window has been hidden
        SDL_WINDOWEVENT_EXPOSED         # Window has been exposed and should be
                                        # redrawn
        SDL_WINDOWEVENT_MOVED           # Window has been moved to data1, data2
        SDL_WINDOWEVENT_RESIZED         # Window has been resized to data1xdata2
        SDL_WINDOWEVENT_SIZE_CHANGED    # The window size has changed, either as
                                        # a result of an API call or through the
                                        # system or user changing the window
                                        # size.
        SDL_WINDOWEVENT_MINIMIZED       # Window has been minimized
        SDL_WINDOWEVENT_MAXIMIZED       # Window has been maximized
        SDL_WINDOWEVENT_RESTORED        # Window has been restored to normal
                                        # size and position
        SDL_WINDOWEVENT_ENTER           # Window has gained mouse focus
        SDL_WINDOWEVENT_LEAVE           # Window has lost mouse focus
        SDL_WINDOWEVENT_FOCUS_GAINED    # Window has gained keyboard focus
        SDL_WINDOWEVENT_FOCUS_LOST      # Window has lost keyboard focus
        SDL_WINDOWEVENT_CLOSE           # The window manager requests that the
                                        # window be closed

    ctypedef void *SDL_GLContext

    enum SDL_GLattr:
        SDL_GL_RED_SIZE
        SDL_GL_GREEN_SIZE
        SDL_GL_BLUE_SIZE
        SDL_GL_ALPHA_SIZE
        SDL_GL_BUFFER_SIZE
        SDL_GL_DOUBLEBUFFER
        SDL_GL_DEPTH_SIZE
        SDL_GL_STENCIL_SIZE
        SDL_GL_ACCUM_RED_SIZE
        SDL_GL_ACCUM_GREEN_SIZE
        SDL_GL_ACCUM_BLUE_SIZE
        SDL_GL_ACCUM_ALPHA_SIZE
        SDL_GL_STEREO
        SDL_GL_MULTISAMPLEBUFFERS
        SDL_GL_MULTISAMPLESAMPLES
        SDL_GL_ACCELERATED_VISUAL
        SDL_GL_RETAINED_BACKING
        SDL_GL_CONTEXT_MAJOR_VERSION
        SDL_GL_CONTEXT_MINOR_VERSION
        SDL_GL_CONTEXT_EGL
        SDL_GL_CONTEXT_FLAGS
        SDL_GL_CONTEXT_PROFILE_MASK
        SDL_GL_SHARE_WITH_CURRENT_CONTEXT
        SDL_GL_FRAMEBUFFER_SRGB_CAPABLE

    enum SDL_GLprofile:
        SDL_GL_CONTEXT_PROFILE_CORE
        SDL_GL_CONTEXT_PROFILE_COMPATIBILITY
        SDL_GL_CONTEXT_PROFILE_ES

    enum SDL_GLcontextFlag:
        SDL_GL_CONTEXT_DEBUG_FLAG
        SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG
        SDL_GL_CONTEXT_ROBUST_ACCESS_FLAG
        SDL_GL_CONTEXT_RESET_ISOLATION_FLAG

    # Video control
    int SDL_GetNumVideoDrivers ()
    const char * SDL_GetVideoDriver (int index)
    int SDL_VideoInit (const char *driver_name)
    void SDL_VideoQuit ()
    
    # Querying
    const char * SDL_GetCurrentVideoDriver ()
    int SDL_GetNumVideoDisplays ()
    const char * SDL_GetDisplayName (int displayIndex)
    #int SDL_GetDisplayBounds (int displayIndex, SDL_Rect * rect)
    int SDL_GetNumDisplayModes (int displayIndex)
    int SDL_GetDisplayMode (int displayIndex, int modeIndex,
        SDL_DisplayMode * mode)
    int SDL_GetDesktopDisplayMode (int displayIndex, SDL_DisplayMode * mode)
    int SDL_GetCurrentDisplayMode (int displayIndex, SDL_DisplayMode * mode)
    SDL_DisplayMode * SDL_GetClosestDisplayMode (int displayIndex,
        const SDL_DisplayMode * mode, SDL_DisplayMode * closest)
    
    # Window control
    int SDL_GetWindowDisplayIndex (SDL_Window * window)
    int SDL_SetWindowDisplayMode (SDL_Window * window,
        const SDL_DisplayMode * mode)
    int SDL_GetWindowDisplayMode (SDL_Window * window, SDL_DisplayMode * mode)
    uint32_t SDL_GetWindowPixelFormat (SDL_Window * window)
    SDL_Window * SDL_CreateWindow (const char *title, int x, int y, int w,
        int h, uint32_t flags)
    SDL_Window * SDL_CreateWindowFrom (const void *data)
    uint32_t SDL_GetWindowID (SDL_Window * window)
    SDL_Window * SDL_GetWindowFromID (uint32_t id)
    uint32_t SDL_GetWindowFlags (SDL_Window * window)
    void SDL_SetWindowTitle (SDL_Window * window, const char *title)
    const char *SDL_GetWindowTitle (SDL_Window * window)
    #void SDL_SetWindowIcon (SDL_Window * window, SDL_Surface * icon)
    void * SDL_SetWindowData (SDL_Window * window, const char *name,
        void *userdata)
    void * SDL_GetWindowData (SDL_Window * window, const char *name)
    void SDL_SetWindowPosition (SDL_Window * window, int x, int y)
    void SDL_GetWindowPosition (SDL_Window * window, int *x, int *y)
    void SDL_SetWindowSize (SDL_Window * window, int w, int h)
    void SDL_GetWindowSize (SDL_Window * window, int *w, int *h)
    void SDL_SetWindowMinimumSize (SDL_Window * window, int min_w, int min_h)
    void SDL_GetWindowMinimumSize (SDL_Window * window, int *w, int *h)
    void SDL_SetWindowMaximumSize (SDL_Window * window, int max_w, int max_h)
    void SDL_GetWindowMaximumSize (SDL_Window * window, int *w, int *h)
    void SDL_SetWindowBordered (SDL_Window * window, bint bordered)
    void SDL_ShowWindow (SDL_Window * window)
    void SDL_HideWindow (SDL_Window * window)
    void SDL_RaiseWindow (SDL_Window * window)
    void SDL_MaximizeWindow (SDL_Window * window)
    void SDL_MinimizeWindow (SDL_Window * window)
    void SDL_RestoreWindow (SDL_Window * window)
    int SDL_SetWindowFullscreen (SDL_Window * window, uint32_t flags)
    #SDL_Surface * SDL_GetWindowSurface (SDL_Window * window)
    int SDL_UpdateWindowSurface (SDL_Window * window)
    #int SDL_UpdateWindowSurfaceRects (SDL_Window * window,
    #    const SDL_Rect * rects, int numrects)
    void SDL_SetWindowGrab (SDL_Window * window, bint grabbed)
    bint SDL_GetWindowGrab (SDL_Window * window)
    int SDL_SetWindowBrightness (SDL_Window * window, float brightness)
    float SDL_GetWindowBrightness (SDL_Window * window)
    int SDL_SetWindowGammaRamp (SDL_Window * window, const uint16_t * red,
        const uint16_t * green, const uint16_t * blue)
    int SDL_GetWindowGammaRamp (SDL_Window * window, uint16_t * red,
        uint16_t * green, uint16_t * blue)
    void SDL_DestroyWindow (SDL_Window * window)
    
    # Display control
    bint SDL_IsScreenSaverEnabled ()
    void SDL_EnableScreenSaver ()
    void SDL_DisableScreenSaver ()
    
    # OpenGL functions
    int SDL_GL_LoadLibrary (const char *path)
    void* SDL_GL_GetProcAddress (const char *proc)
    void SDL_GL_UnloadLibrary ()
    bint SDL_GL_ExtensionSupported (const char *extension)
    void SDL_GL_ResetAttributes ()
    int SDL_GL_SetAttribute (SDL_GLattr attr, int value)
    int SDL_GL_GetAttribute (SDL_GLattr attr, int *value)
    SDL_GLContext SDL_GL_CreateContext (SDL_Window * window)
    int SDL_GL_MakeCurrent (SDL_Window * window, SDL_GLContext context)
    SDL_Window * SDL_GL_GetCurrentWindow ()
    SDL_GLContext SDL_GL_GetCurrentContext ()
    void SDL_GL_GetDrawableSize (SDL_Window * window, int *w, int *h)
    int SDL_GL_SetSwapInterval (int interval)
    int SDL_GL_GetSwapInterval ()
    void SDL_GL_SwapWindow (SDL_Window * window)
    void SDL_GL_DeleteContext (SDL_GLContext context)

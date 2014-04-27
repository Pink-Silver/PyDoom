# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

include_directories ("${PYTHON_INCLUDE_DIRS}" "${SDL_INCLUDE_DIR}")

add_executable (PyDoom
    main.cpp
    toplevel.cpp
)

target_link_libraries (PyDoom "${PYTHON_LIBRARIES}" "${SDL_LIBRARY}" "${SDLMAIN_LIBRARY}")

install (TARGETS PyDoom DESTINATION ${CMAKE_INSTALL_PREFIX})

# Need to do this on Windows because SDL isn't a system library there.
if (WIN32)
    find_file (PyDoom_SDL_LIBRARY SDL2.dll
        HINTS
            ENV SDLDIR
        PATH_SUFFIXES lib
        )
    install (FILES ${PyDoom_SDL_LIBRARY} DESTINATION ${CMAKE_INSTALL_PREFIX})
endif ()

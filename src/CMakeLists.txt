# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

include_directories ("${PYTHON_INCLUDE_DIRS}" "${SDL_INCLUDE_DIR}"
    "${PyDoom_BINARY_DIR}/src")

add_custom_command (
    OUTPUT ${PyDoom_BINARY_DIR}/src/video.cpp ${PyDoom_BINARY_DIR}/src/video.h
    COMMAND Cython --cplus -3 -o ${PyDoom_BINARY_DIR}/src/video.cpp ${PyDoom_SOURCE_DIR}/src/video.pyx
)

add_executable (PyDoom
    # Globals
    global.hpp

    # Main Program
    main.cpp
    pydoom.rc

    # Modules
    ${PyDoom_BINARY_DIR}/src/video.h
    ${PyDoom_BINARY_DIR}/src/video.cpp
)

target_link_libraries (PyDoom "${PYTHON_LIBRARIES}" "${SDL_LIBRARY}" "${SDLMAIN_LIBRARY}" "${OPENGL_LIBRARIES}")

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

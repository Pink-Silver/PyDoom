# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

include_directories ("${PYTHON_INCLUDE_DIRS}" "${SDL_INCLUDE_DIR}"
    "${PyDoom_SOURCE_DIR}/extern/glew-1.11.0/include" "${PyDoom_SOURCE_DIR}/src"
    "${PyDoom_BINARY_DIR}/src")

function (add_pyx_file name)
    add_custom_command (
        OUTPUT ${PyDoom_BINARY_DIR}/src/${name}.cpp
        COMMAND Cython --annotate --cplus -3
            -o ${PyDoom_BINARY_DIR}/src/${name}.cpp
            ${PyDoom_SOURCE_DIR}/src/${name}.pyx
    )
endfunction (add_pyx_file)

add_custom_command (
    OUTPUT ${PyDoom_BINARY_DIR}/src/main.cpp
    COMMAND Cython --annotate --embed --cplus -3
        -o ${PyDoom_BINARY_DIR}/src/main.cpp
        ${PyDoom_SOURCE_DIR}/src/main.pyx
)

add_pyx_file (pydoom/__init__)
add_pyx_file (pydoom/arguments)
add_pyx_file (pydoom/configuration)
add_pyx_file (pydoom/games)
add_pyx_file (pydoom/graphics)
add_pyx_file (pydoom/resources)
add_pyx_file (pydoom/utility)
add_pyx_file (pydoom/version)
add_pyx_file (pydoom/video)

add_executable (PyDoom
    # Main Program
    global.hpp
    main.cpp
    pydoom.rc

    video_cpp.hpp
    video_cpp.cpp

    # Modules
    pydoom/__init__.pyx
    ${PyDoom_BINARY_DIR}/src/pydoom/__init__.cpp
    pydoom/arguments.pyx
    ${PyDoom_BINARY_DIR}/src/pydoom/arguments.cpp
    pydoom/configuration.pyx
    ${PyDoom_BINARY_DIR}/src/pydoom/configuration.cpp
    pydoom/games.pyx
    ${PyDoom_BINARY_DIR}/src/pydoom/games.cpp
    pydoom/graphics.pyx
    ${PyDoom_BINARY_DIR}/src/pydoom/graphics.cpp
    pydoom/resources.pyx
    ${PyDoom_BINARY_DIR}/src/pydoom/resources.cpp
    pydoom/utility.pyx
    ${PyDoom_BINARY_DIR}/src/pydoom/utility.cpp
    pydoom/version.pyx
    ${PyDoom_BINARY_DIR}/src/pydoom/version.cpp
    pydoom/video.pyx
    ${PyDoom_BINARY_DIR}/src/pydoom/video.cpp
)

target_link_libraries (PyDoom "${PYTHON_LIBRARIES}" "${SDL_LIBRARY}"
    "${SDLMAIN_LIBRARY}" "${OPENGL_LIBRARIES}"
    "${PyDoom_SOURCE_DIR}/extern/glew-1.11.0/lib/Release/Win32/glew32.lib")

install (TARGETS PyDoom DESTINATION ${CMAKE_INSTALL_PREFIX})

# Need to do this on Windows because SDL isn't a system library there.
if (WIN32)
    find_file (PyDoom_SDL_LIBRARY SDL2.dll
        HINTS
            ENV SDLDIR
        PATH_SUFFIXES lib
        )
    install (FILES ${PyDoom_SDL_LIBRARY} DESTINATION ${CMAKE_INSTALL_PREFIX})
    install (FILES "${PyDoom_SOURCE_DIR}/extern/glew-1.11.0/bin/Release/Win32/glew32.dll" DESTINATION ${CMAKE_INSTALL_PREFIX})
endif ()

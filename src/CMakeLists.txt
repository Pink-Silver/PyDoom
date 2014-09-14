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

add_pyx_file (arguments)
add_pyx_file (configuration)
add_pyx_file (games)
add_pyx_file (graphics)
add_pyx_file (resources)
add_pyx_file (utility)
add_pyx_file (version)
add_pyx_file (video)

add_executable (PyDoom
    # Main Program
    global.hpp
    main.cpp
    pydoom.rc

    video_cpp.hpp
    video_cpp.cpp

    # Modules
    arguments.pyx
    ${PyDoom_BINARY_DIR}/src/arguments.cpp
    configuration.pyx
    ${PyDoom_BINARY_DIR}/src/configuration.cpp
    games.pyx
    ${PyDoom_BINARY_DIR}/src/games.cpp
    graphics.pyx
    ${PyDoom_BINARY_DIR}/src/graphics.cpp
    resources.pyx
    ${PyDoom_BINARY_DIR}/src/resources.cpp
    utility.pyx
    ${PyDoom_BINARY_DIR}/src/utility.cpp
    version.pyx
    ${PyDoom_BINARY_DIR}/src/version.cpp
    video.pyx
    ${PyDoom_BINARY_DIR}/src/video.cpp
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

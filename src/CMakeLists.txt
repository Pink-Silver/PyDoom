# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

include_directories ("${PYTHON_INCLUDE_DIRS}" "${SDL_INCLUDE_DIR}"
    "${PyDoom_SOURCE_DIR}/extern/glew-1.11.0/include" "${PyDoom_SOURCE_DIR}/src"
    "${PyDoom_BINARY_DIR}/src")

function (generate_pyx_file name)
    add_custom_command (
        OUTPUT ${PyDoom_BINARY_DIR}/src/${name}.cpp
        COMMAND Cython --annotate --cplus -3
            -o ${PyDoom_BINARY_DIR}/src/${name}.cpp
            ${PyDoom_SOURCE_DIR}/src/${name}.pyx
    )
endfunction (generate_pyx_file)

function (bare_pyx_library name)
    generate_pyx_file (${name})
    
    add_library (${name}.pyd MODULE
        ${PyDoom_BINARY_DIR}/src/${name}.cpp
    )

    target_link_libraries (${name}.pyd "${PYTHON_LIBRARY}")
    
    install(TARGETS ${name}.pyd DESTINATION ${CMAKE_INSTALL_PREFIX})
endfunction (bare_pyx_library name)

bare_pyx_library (arguments)
bare_pyx_library (configuration)
bare_pyx_library (games)
bare_pyx_library (graphics)
bare_pyx_library (resources)
bare_pyx_library (utility)
bare_pyx_library (version)

generate_pyx_file (video)
add_library (video.pyd MODULE
    video_cpp.hpp
    video_cpp.cpp
    
    ${PyDoom_BINARY_DIR}/src/video.cpp
)
target_link_libraries (video.pyd "${PYTHON_LIBRARY}" "${SDL_LIBRARY}"
    "${OPENGL_LIBRARIES}"
    "${PyDoom_SOURCE_DIR}/extern/glew-1.11.0/lib/Release/Win32/glew32.lib")
install(TARGETS video.pyd DESTINATION ${CMAKE_INSTALL_PREFIX})

# Main program
add_custom_command (
    OUTPUT ${PyDoom_BINARY_DIR}/src/main.cpp
    COMMAND Cython --annotate --embed --cplus -3
        -o ${PyDoom_BINARY_DIR}/src/main.cpp
        ${PyDoom_SOURCE_DIR}/src/main.pyx
)

add_executable (PyDoom
    global.hpp
    main.cpp
    pydoom.rc
)

target_link_libraries (PyDoom "${PYTHON_LIBRARY}" "${SDL_LIBRARY}"
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

configure_file (
    "columnrender_setup.py.in"
    "${PyDoom_BINARY_DIR}/columnrender_setup.py"
    )

add_custom_target (ColumnRenderer ALL
    ${PYTHON_EXECUTABLE} "${PyDoom_BINARY_DIR}/columnrender_setup.py"
    "build_ext" "--build-lib" "${PyDoom_BINARY_DIR}")

install (FILES "${PyDoom_BINARY_DIR}/columnrenderer.pyd" DESTINATION ${CMAKE_INSTALL_PREFIX})

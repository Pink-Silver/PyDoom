# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

configure_file (
    "columnrender_setup.in.py"
    "${PyDoom_BINARY_DIR}/columnrender_setup.py"
    )

add_custom_target (ColumnRenderer ALL
    ${PYTHON_EXECUTABLE} "${PyDoom_BINARY_DIR}/columnrender_setup.py"
    "build_ext" "--build-lib" "${PyDoom_BINARY_DIR}")

install (FILES "${PyDoom_BINARY_DIR}/columnrenderer.pyd" DESTINATION ${CMAKE_INSTALL_PREFIX})

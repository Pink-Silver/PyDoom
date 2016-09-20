# Copyright (c) 2014, Kate Fox
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

cdef extern from "cutility.h":
    int util_initsdl ()
    void util_quitsdl ()
    double timer_tick ()

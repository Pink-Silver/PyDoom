# Copyright (c) 2014, Kate Fox
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

cimport cutility

def initialize ():
    cutility.util_initsdl ()

def shutdown ():
    cutility.util_quitsdl ()

def tick ():
    return cutility.timer_tick ()

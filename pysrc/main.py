# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

from version import GITVERSION
from time import sleep
from sys import argv, path
import arguments

def main ():
    print ("=== PyDoom revision {} ===".format (GITVERSION))
    args = arguments.ArgumentParser (argv[1:])
    args.CollectArgs ()
    del args
    sleep (20)

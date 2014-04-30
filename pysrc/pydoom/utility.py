# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

def measuresize (size):
    sizetable = [
        ("TB", 1024 ** 4),
        ("GB", 1024 ** 3),
        ("MB", 1024 ** 2),
        ("KB", 1024),
    ]
    
    suffix = "B"
    for i in range (len (sizetable)):
        if size / sizetable[i][1] >= 1:
            suffix = sizetable[i][0]
            size /= sizetable[i][1]
    
    return "{:.2f}{}".format (size, suffix)

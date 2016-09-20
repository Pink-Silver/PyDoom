# Copyright (c) 2014, Kate Fox
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

import zipfile, os.path
from os import walk
from sys import argv

def main (inpath, outpath):
    inpath  = os.path.normpath (inpath)
    outpath = os.path.normpath (outpath)
    if not os.path.exists (inpath):
        raise ValueError ("{} does not exist!".format (inpath))
    outfile = outpath
    print ("Writing {}...".format (outfile))
    
    with zipfile.ZipFile (outfile, "w") as openedzip:
        total = 0
        for dir, subdirs, files in walk (inpath):
            for file in files:
                aname = os.path.join (dir, file)[len(inpath)+1:]
                print ("- Adding {}".format (aname))
                openedzip.write (os.path.join (dir, file), arcname=aname)
                total += 1
    
    print ("{} total file{} written.".format (total, ("s" if total != 1 else "")))

if __name__ == "__main__":
    main (argv[1], argv[2])

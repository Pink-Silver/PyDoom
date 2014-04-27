import zipfile, glob, os.path
from sys import argv
from os import listdir

def main (inpath, outpath):
    inpath  = os.path.normpath (inpath)
    outpath = os.path.normpath (outpath)
    if not os.path.exists (inpath):
        raise ValueError ("{} does not exist!".format (inpath))
    outfile = os.path.join (outpath, "PyDoom.zip")
    print ("Writing {}...".format (outfile))

    with zipfile.ZipFile (outfile, "w") as openedzip:
        fnames = listdir (inpath)
        total = 0

        for fn in fnames:
            print ("- Adding {}".format (fn))
            openedzip.write (os.path.join (inpath, fn), arcname=fn)
            total += 1

    print ("{} total file{} written.".format (total, ("s" if total != 1 else "")))

if __name__ == "__main__":
    main (argv[1], argv[2])

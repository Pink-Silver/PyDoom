import zipfile, glob, os.path
from sys import argv

def main (path):
    outfile = os.path.join (path, "PyDoom.zip")
    print ("Writing {}...".format (outfile))

    with zipfile.ZipFile (outfile, "w") as openedzip:
        fnames = glob.iglob ("pysrc/*")
        total = 0

        for fn in fnames:
            name = "/".join (os.path.split (fn)[1:])
            print ("- Adding {}".format (name))
            openedzip.write (fn, arcname=name)
            total += 1

    print ("{} total file(s) written.".format (total))

if __name__ == "__main__":
    main (argv[1])

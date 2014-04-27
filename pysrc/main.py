from version import GITVERSION
from time import sleep
from sys import argv, path
import columnrenderer

def main ():
    print ("=== PyDoom revision {} ===".format (GITVERSION))
    print ("Received arguments: {} ({} total)".format (" ".join (argv), len (argv)))
    print ("Current Python paths: {} ({} total)".format (", ".join (path), len (path)))
    sleep (20)

# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

class ArgumentParser:
    """A reader for command-line arguments passed to the game."""
    def __init__ (self, arglist):
        self.args = arglist
        
        # Files
        self.iwad = None
        self.pwads = []
        
        # Warping / Starting
        self.map = None
        self.skill = None
        self.savegame = None
        self.playdemo = None
        
        # Configuration options
        self.resolution = None
        self.fullscreen = None
    
    def CollectArgs (self):
        """Consumes arguments until there are none left, calling
        functions between each new option to set the appropriate
        properties."""
        argindex = 1
        optlist = []
        while self.args:
            if self.IsOption (self.args[0]):
                if optlist:
                    print ("{}: {}".format (argindex, " ".join (optlist))) # For now
                    argindex += 1
                
                optlist = [self.args.pop (0)[1:]]
            else:
                optlist.append (self.args.pop (0))
        
        if optlist:
            print ("{}: {}".format (argindex, " ".join (optlist))) # For now
    
    def IsOption (self, item):
        """Returns True if the argument is the start of a new
        option."""
        if item[0] == '-' or item[0] == '+':
            return True
        
        return False

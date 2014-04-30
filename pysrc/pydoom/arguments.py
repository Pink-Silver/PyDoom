# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

import os.path

class ArgumentParser:
    """A reader for command-line arguments passed to the game."""
    def __init__ (self, arglist):
        self.args = arglist
        
        # Files
        self.iwad  = None
        self.pwads = []
        
        # Warping / Starting
        self.map      = None
        self.skill    = None
        self.savegame = None
        self.playdemo = None
        
        # Configuration options
        self.resolution = [None, None]
        self.fullscreen = None
        self.renderer   = None
    
    def IsOption (self, item):
        """Returns True if the argument is the start of a new
        option."""
        if item[0] == '-':
            return True
        
        return False

    def CollectArgs (self):
        """Consumes arguments until there are none left, calling
        functions between each new option to set the appropriate
        properties."""
        argindex = 1
        optlist = []
        while self.args:
            if self.IsOption (self.args[0]):
                if optlist:
                    self.ParseOptions (optlist)
                    argindex += 1
                
                optlist = [self.args.pop (0)[1:]]
            else:
                optlist.append (self.args.pop (0))
        
        if optlist:
            self.ParseOptions (optlist)
    
    def ParseOptions (self, options):
        command = options.pop (0)
        command = command.lower ()
        parsefunc = None
        try:
            parsefunc = self.__class__.__dict__['ParseOpt_{}'.format (command)]
        except KeyError:
            print ("Unknown option '{}'".format (command))
            return
        
        try:
            parsefunc (self, *options)
        except (TypeError, ValueError) as ex:
            print ("Bad arguments for option '{}'".format (command))
            print ("  Proper use: {}".format (parsefunc.__doc__))
    
    def ParseOpt_iwad (self, iwad):
        "-iwad filename.wad"
        if not os.path.exists (iwad):
            raise ValueError ("The IWAD '{}' does not exist!".format (iwad))
        self.iwad = iwad
    
    def ParseOpt_file (self, *files):
        "-file file1.wad[, file2.wad[, ...]]"
        if not files:
            raise ValueError ("No files")
        
        for f in files:
            if not os.path.exists (f):
                print ("The added file '{}' does not exist. Ignoring.".format (f))
                continue
            
            self.pwads.append (f)
    
    def ParseOpt_warp (self, episode, level=None):
        "-warp [episode] map"
        if level is None:
            level = episode
            episode = None
        
        if episode is not None:
            episode = int (episode)
        
        self.map = (episode, int (level))
    
    def ParseOpt_skill (self, skill):
        "-skill skill"
        self.skill = int (skill)
    
    def ParseOpt_loadgame (self, name):
        "-loadgame filename.sav"
        self.savegame = name
    
    def ParseOpt_playdemo (self, name):
        "-playdemo filename.lmp"
        self.playdemo = name
    
    def ParseOpt_fullscreen (self):
        "-fullscreen"
        self.fullscreen = True
    
    def ParseOpt_windowed (self):
        "-windowed"
        self.fullscreen = False
    
    def ParseOpt_width (self, width):
        "-width screenwidth"
        self.resolution[0] = int (width)
    
    def ParseOpt_height (self, height):
        "-height screenheight"
        self.resolution[1] = int (height)
    
    def ParseOpt_renderer (self, rendertype):
        "-renderer software|opengl"
        self.renderer = rendertype

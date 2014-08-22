# Copyright (c) 2014, Kate Stone
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

import tkinter
import tkinter.filedialog
from sys import argv
from glob import iglob
from os.path import join as joinpath
from os.path import basename as filename

class GameSelector (tkinter.Frame):
    def __init__ (self, games, master=None):
        self.games = games
        self.selectedgame = None
        self.quitting = False

        tkinter.Frame.__init__ (self, master)
        master.title ("PyDoom: Choose a Game")
        master.minsize (400, 300)
        master.iconbitmap (argv[0])
        master.deiconify ()
        self.pack (fill="both", expand=True, padx=2, pady=2)
        self.createWidgets ()

    def createWidgets (self):
        self.games_frame = tkinter.Frame (self)
        self.games_frame.pack (side="top", fill="both", expand=True)

        self.games_dirtop_frame = tkinter.Frame (self.games_frame)
        self.games_dirtop_frame.pack (side="top", fill="x")

        self.games_dirtop_text = tkinter.Label (self.games_dirtop_frame)
        self.games_dirtop_text["text"] = "Select a game to load, then click \
'OK'."
        self.games_dirtop_text.pack (side="top")

        self.games_list = tkinter.Listbox (self.games_frame)
        self.games_list.pack (side="top", fill="both", expand=True)
        self.games_list.delete (0, "end")
        for game in self.games:
            self.games_list.insert ("end", game.game_title)

        self.okcancel_frame = tkinter.Frame (self)
        self.okcancel_frame["height"] = "32"
        self.okcancel_frame.pack (side="bottom", fill="x")
        self.cancel = tkinter.Button (self.okcancel_frame, text="Cancel",
            command=self.quit)
        self.cancel.pack (side="right", fill="x", expand=True)
        self.ok = tkinter.Button (self.okcancel_frame, text="OK",
            command=self.selectGame)
        self.ok.pack (side="left", fill="x", expand=True)

    def quit (self):
        self.quitting = True
        self.master.destroy ()

    def selectGame (self):
        selection = self.games_list.curselection ()
        if not selection:
            return
        self.selectedgame = self.games[selection[0]]
        self.quit ()

def selectGame (gamelist):
    root = tkinter.Tk ()

    dialog = GameSelector (games=gamelist, master=root)
    while not dialog.quitting:
        dialog.mainloop (1)
    selected = dialog.selectedgame

    return selected

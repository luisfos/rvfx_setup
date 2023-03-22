'''
Luis Fos

TODO:
cleanup row deletion
add run script to make the symlinks

'''


import os
import tkinter as tk
from tkinter import filedialog
import toml

CONFIG_FILE = "config.toml"
DEFAULT_CONFIG = """\
["python39"]
filepath = 'C:\\Users\\luisf\\AppData\\Local\\Programs\\Python\\Python39\\python.exe'
symlink = 'python39.exe'

["houdini"]
filepath= 'C:\\Program Files\\Side Effects Software\\Houdini 19.5.435\\bin\\hython.exe'
symlink = 'hython.exe'
"""

class Application(tk.Frame):
    def __init__(self, master=None):
        super().__init__(master)
        self.master = master
        self.master.geometry("900x300") # set initial size of the window
        # self.master.columnconfigure(0, weight=1)
        # self.master.rowconfigure(0, weight=1)
        self.create_widgets()
        self.load_config()

    def create_widgets(self):
        self.entries = []
        self.row = 0        
        self.add_button = tk.Button(self.master, text="Add Entry", command=self.add_entry)
        self.add_button.grid(row=self.row, column=0)
        self.save_button = tk.Button(self.master, text="Save Changes", command=self.save_config)
        self.save_button.grid(row=self.row, column=1)
        self.row += 1
        self.headerId_label = tk.Label(self.master, text="Id.")
        self.headerId_label.grid(row=self.row, column=0)
        self.headerName_label = tk.Label(self.master, text="Name")
        self.headerName_label.grid(row=self.row, column=1)
        self.headerSymlink_label = tk.Label(self.master, text="Symlink")
        self.headerSymlink_label.grid(row=self.row, column=2)
        self.headerFilepath_label = tk.Label(self.master, text="Filepath")
        self.headerFilepath_label.grid(row=self.row, column=3)
        self.row += 1

    def add_entry(self):
        entry = EntryForm(self.master, self.row, app=self)
        self.entries.append(entry)
        self.row += 1

    def save_config(self):
        config = {}
        for entry in self.entries:
            config[entry.name_var.get()] = {
                "filepath": entry.filepath_var.get(),
                "symlink": entry.symlink_var.get()
            }
        with open(CONFIG_FILE, "w") as f:
            toml.dump(config, f)

    def load_config(self):
        if not os.path.exists(CONFIG_FILE):
            with open(CONFIG_FILE, "w") as f:
                f.write(DEFAULT_CONFIG)
        with open(CONFIG_FILE, "r") as f:
            config = toml.load(f)
        for name, values in config.items():
            entry = EntryForm(self.master, self.row, app=self, name=name, filepath=values["filepath"], symlink=values["symlink"])
            self.entries.append(entry)
            self.row += 1

    def remove_entry(self, entry):
        # Remove the instance from the entries list
        self.entries.remove(entry)

        # Adjust the row numbering of the remaining instances
        for other_entry in self.entries:
            if other_entry.row > entry.row:
                other_entry.row -= 1

        # Destroy the widget in the UI
        for widget in self.master.grid_slaves():
            if int(widget.grid_info()["row"]) == entry.row:
                widget.destroy()


class EntryForm:
    def __init__(self, master, row, app, name="", filepath="", symlink=""):
        self.master = master
        self.row = row
        self.app = app

        if len(name) == 0:
            name = "houdini"        
        if len(symlink) == 0: 
            symlink = "hython.exe"
        if len(filepath) == 0: 
            filepath = r"path\to\hython.exe"        

        self.name_var = tk.StringVar(value=name) 
        self.filepath_var = tk.StringVar(value=filepath)
        self.symlink_var = tk.StringVar(value=symlink)
        self.create_widgets()

    def create_widgets(self):
        id_label = tk.Label(self.master, text=str(self.row-1)+'.')
        id_label.grid(row=self.row, column=0)
        name_entry = tk.Entry(self.master, textvariable=self.name_var)
        name_entry.grid(row=self.row, column=1)
        symlink_entry = tk.Entry(self.master, textvariable=self.symlink_var)
        symlink_entry.grid(row=self.row, column=2)
        filepath_entry = tk.Entry(self.master, textvariable=self.filepath_var, width=70)
        filepath_entry.grid(row=self.row, column=3)
        filepath_button = tk.Button(self.master, text="Browse", command=self.browse_file)
        filepath_button.grid(row=self.row, column=4)
        remove_button = tk.Button(self.master, text="❌", command=self.remove)
        remove_button.grid(row=self.row, column=5)

    def browse_file(self):
        filepath = filedialog.askopenfilename()
        if filepath:
            self.filepath_var.set(filepath)

    def remove(self):        
        self.app.remove_entry(self)
        # Remove this instance from the UI
        # for widget in self.master.grid_slaves():
        #     if int(widget.grid_info()["row"]) == self.row:
        #         widget.destroy()
        # # # Adjust the row numbering of the remaining instances
        # for entry in self.master.entries:
        #     if entry.row > self.row:
        #         entry.row -= 1

root = tk.Tk()
app = Application(master=root)
app.mainloop()

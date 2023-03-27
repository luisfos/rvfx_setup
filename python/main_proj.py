'''
Luis Fos
22/03/2023

TODO:
cleanup row deletion
add run script to make the symlinks
fix filebrowser to select on folder
fix save changes error on name key

'''

import os
import subprocess
from pathlib import Path
import tkinter as tk
from tkinter import filedialog
import toml

DIRECTORY = Path(r"..\projects")
CONFIG_FILE = "config_proj.toml"
DEFAULT_CONFIG = """\
[19_maybelline]
path = 'E:\\Projects\\RockinVFX\\19_Maybelline'
symlink = "19_maybelline"
"""

class Application(tk.Frame):
    def __init__(self, master=None):
        super().__init__(master)
        self.master = master
        # self.master.geometry("900x300") # set initial size of the window, remove to auto adjust
        self.master.minsize(500,300)
        self.master.configure(bg='#e3d5c3')
        
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
        self.action_button = tk.Button(self.master, text="Make Symlinks", command=self.make_symlinks)
        self.action_button.grid(row=self.row, column=3)
        self.row += 1
        self.headerId_label = tk.Label(self.master, text="Id.", width=3)
        self.headerId_label.grid(row=self.row, column=0)        
        self.headerName_label = tk.Label(self.master, text="Project Name", width=12)
        self.headerName_label.grid(row=self.row, column=1)
        self.headerPath_label = tk.Label(self.master, text="Local Project Path")
        self.headerPath_label.grid(row=self.row, column=2)
        self.row += 1

    def add_entry(self):
        entry = EntryForm(self.master, self.row, app=self)
        self.entries.append(entry)
        self.row += 1

    def save_config(self):
        config = {}
        for entry in self.entries:
            config[entry.name_var.get()] = {
                "path": entry.filepath_var.get(),
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
            entry = EntryForm(self.master, self.row, app=self, filepath=values["path"], symlink=values["symlink"])
            self.entries.append(entry)
            self.row += 1

    def make_symlinks(self):
        for entry in self.entries:            
            source = entry.filepath_var.get()
            symlink = entry.symlink_var.get()
            target = DIRECTORY / symlink
            target = target.resolve()
            print(target)
            self.create_windows_symlink(source,target)
        

    def create_windows_symlink(self,source,target):
         # Check if the source file exists
        if not os.path.exists(source):
            print(f"Error: Source file {source} does not exist")
            return

        # Check if the target file already exists
        if os.path.exists(target):
            print(f"Error: Target file {target} already exists")
            return

        # check if project folder exists
        if not os.path.exists(target.parent):
            target.parent.mkdir(parents=True, exist_ok=True)

        # Create the symlink using the mklink command
        # os.system(f"mklink \"{target}\" \"{source}\"")
        # print(f"Symlink created from {source} to {target}")
        # Create the symlink using the mklink command
        cmd = f"mklink /D \"{target}\" \"{source}\""
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        out, err = proc.communicate()
        if err:
            print(f"Error creating symlink: {err.decode('utf-8')}")
            print(f"Command was: {cmd}")
        else:
            print(f"Symlink created from {source} to {target}")
        if out:
            print(f"Command output: {out.decode('utf-8')}")


    def remove_entry(self, entry):
        # Remove the instance from the entries list
        self.entries.remove(entry)
        self.row -= 1

        # Adjust the row numbering of the remaining instances
        for other_entry in self.entries:
            if other_entry.row > entry.row:
                other_entry.row -= 1

        # Destroy the widget in the UI
        for widget in self.master.grid_slaves():
            if int(widget.grid_info()["row"]) == entry.row:
                widget.destroy()


class EntryForm:
    def __init__(self, master, row, app, filepath="", symlink=""):
        self.master = master
        self.row = row
        self.app = app
                
        if len(symlink) == 0: 
            symlink = "hython.exe"
        if len(filepath) == 0: 
            filepath = r"path\to\hython.exe"        

        self.filepath_var = tk.StringVar(value=filepath)
        self.symlink_var = tk.StringVar(value=symlink)
        self.create_widgets()

    def create_widgets(self):
        id_label = tk.Label(self.master, text=str(self.row-1)+'.', width=3)
        id_label.grid(row=self.row, column=0)        
        symlink_entry = tk.Entry(self.master, textvariable=self.symlink_var, width=15)
        symlink_entry.grid(row=self.row, column=1)
        filepath_entry = tk.Entry(self.master, textvariable=self.filepath_var, width=70)
        filepath_entry.grid(row=self.row, column=2)
        filepath_button = tk.Button(self.master, text="Browse", command=self.browse_file)
        filepath_button.grid(row=self.row, column=3)
        remove_button = tk.Button(self.master, text="❌", command=self.remove)
        remove_button.grid(row=self.row, column=4)

    def browse_file(self):
        filepath = filedialog.askopenfilename()
        if filepath:
            self.filepath_var.set(filepath)

    def remove(self): 
        # print("I am being removed, my ID is: ", self.row-1)       
        self.app.remove_entry(self)


root = tk.Tk()
app = Application(master=root)
app.mainloop()

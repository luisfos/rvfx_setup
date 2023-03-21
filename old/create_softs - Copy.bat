@echo off
setlocal enabledelayedexpansion

set "config_file=%~dp0softs.cfg"
set "symlink_dir=%~dp0..\soft"

for /f "usebackq delims=" %%a in ("%config_file%") do (
  set "line=%%a"
  if "!line:~0,1!"=="[" (
    echo Creating symlinks for !app_name!...
    set "app_name=!line:~1,-1!"
  ) else if not "!line:~0,1!"=="#" (
    for /f "tokens=1,2" %%b in ("!line!") do (
      set "target_file=%%b"
      set "symlink_name=%%c"
      echo Target file: !target_file!
      echo Symlink name: !symlink_name!
      mklink "%symlink_dir%\!symlink_name!" "!target_file!" >nul
      if errorlevel 1 echo Failed to create symlink for !app_name! - %symlink_name%
    )
  )
)
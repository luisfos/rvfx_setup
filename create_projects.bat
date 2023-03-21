@echo off

REM Read the configuration file
for /F "usebackq delims== tokens=1,2" %%G in ("symlinks.cfg") do (
    set "%%G=%%H"
)

REM Loop through the sections in the configuration file
for /F "tokens=1 delims=[]" %%G in ('find /N "[section]" symlinks.cfg') do (
    set "section=%%G"
    set /a "section+=1"

    REM Get the source and target paths from the section
    call set "source=%%section_[%section%]_source%%"
    call set "target=%%section_[%section%]_target%%"

    REM Check if the section is commented out
    if not "!source!"=="!source:#=!" (
        REM If it is, skip the section
        echo Skipping section %section%
        continue
    )

    REM Create the symbolic link
    mklink /D "%target%" "%source%"

    REM Print a message indicating that the symlink was created
    echo Created symlink from %source% to %target%
)

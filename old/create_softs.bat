@echo off

REM Read the configuration file
setlocal enabledelayedexpansion
for /F "tokens=1,* delims=[]" %%G in ('find /v /n "" ^< "executables.cfg"') do (
    if "%%H" neq "" (
        set "section=%%H"
    ) else (
        set "line=%%~nxH"
        set "exe=!line:[=!"
        set "exe=!exe:]=!"
        set "linkName=!line:*]=!"
        
        REM Create a symbolic link to the executable
        mklink "!section!\!linkName!.lnk" "!exe!" 2>NUL
        if %errorlevel% neq 0 (
            echo Failed to create symlink for !exe!
        ) else (
            echo Created symlink !section!\!linkName!.lnk for !exe!
        )
    )
)
@ECHO OFF

TITLE Console

:back
    CLS
    ECHO 1. Run FakeCursor.lua with input.json
    ECHO 2. Close run.bat
    ECHO.
    CHOICE /C 12 /N /M "Enter your choice: "
    :: Note - list ERRORLEVELS in decreasing order
    IF ERRORLEVEL 2 GOTO CloseAllWindows
    IF ERRORLEVEL 1 GOTO RunFakeCursor

:RunFakeCursor
    ECHO.
    ECHO BEFORE RUNNING PLEASE MAKE SURE YOU PUT YOUR MAP IN 'input.json' AND SONG LENGTH IN 'length.lua'
    ECHO.
    ECHO 1. Yes
    ECHO 2. No
    ECHO.
    CHOICE /C 12 /N /M "Are you sure you want to run FakeCursor.lua: "
    IF ERRORLEVEL 2 GOTO back
    IF ERRORLEVEL 1 GOTO ComfirmFakeCursor

:ComfirmFakeCursor
    ECHO.
    .\lua\lua53.exe ./FakeCursor.lua
    ECHO.
    pause
    GOTO CloseAllWindows

:CloseAllWindows
    ECHO.
    ECHO Exiting...
    timeout /T 2
    ::GOTO CLSback
    Exit

pause
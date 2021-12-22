@ECHO OFF

TITLE Console

:back
    CLS
    ECHO 1. Run FakeCursor.lua with input.txt
    ECHO 2. Run ConvertMap.lua with input.txt
    ECHO 3. Close run.bat
    ECHO.
    CHOICE /C 12 /N /M "Enter your choice: "
    :: Note - list ERRORLEVELS in decreasing order
    IF ERRORLEVEL 3 GOTO CloseAllWindows
    IF ERRORLEVEL 2 GOTO RunConvertMap
    IF ERRORLEVEL 1 GOTO RunFakeCursor

:RunConvertMap
    ECHO.
    ECHO BEFORE RUNNING PLEASE MAKE SURE YOU PUT YOUR MAP IN 'input.txt'
    ECHO.
    ECHO 1. Yes
    ECHO 2. No
    ECHO.
    CHOICE /C 12 /N /M "Are you sure you want to run ConvertMap.lua: "
    IF ERRORLEVEL 2 GOTO back
    IF ERRORLEVEL 1 GOTO ComfirmConvertMap

:ComfirmConvertMap
    ECHO.
    .\lua\lua53.exe ./ConvertMap.lua
    ECHO.
    pause
    GOTO CloseAllWindows

:RunFakeCursor
    ECHO.
    ECHO BEFORE RUNNING PLEASE MAKE SURE YOU PUT YOUR MAP IN 'input.txt' AND SONG LENGTH IN 'length.lua'
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
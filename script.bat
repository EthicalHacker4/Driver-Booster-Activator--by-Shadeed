@echo off
setlocal enabledelayedexpansion

:: Enable ANSI escape processing (Windows 10+)
for /f "tokens=2 delims=: " %%i in ('reg query HKCU\Console ^| findstr VirtualTerminalLevel') do set "VT_ENABLED=%%i"
if not defined VT_ENABLED (
    reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
)

:: Script directories
set "SCRIPT_DIR=%~dp0"
set "SRC_DIR=%SCRIPT_DIR%src\"
set "DEFAULT_DEST_DIR=C:\Program Files (x86)\IObit\Driver Booster\13.0.0"

:: Encoded files
set "ENCODED_FILE=%SRC_DIR%encoded.txt"
set "ENCODED_ASCII_ART=%SRC_DIR%encoded_ascii_art.txt"

:: Colors (ANSI)
set "RESET=[0m"
set "GREEN=[32m"
set "RED=[31m"

:: Admin rights check
net session >nul 2>&1
if errorlevel 1 (
    echo %RED%You need to run this script as Administrator. Right-click and choose "Run as Administrator".%RESET%
    pause
    exit /b
)

echo %GREEN%Running with administrative privileges...%RESET%
echo Decoding encoded files...

:: Decode main file
powershell -Command "[System.IO.File]::WriteAllBytes('%TEMP%\decoded_file.txt', [System.Convert]::FromBase64String((Get-Content \"%ENCODED_FILE%\" -Raw)))"
if errorlevel 1 (
    echo %RED%Failed to decode main file.%RESET%
    pause
    exit /b
)

:: Decode ASCII art
powershell -Command "[System.IO.File]::WriteAllBytes('%TEMP%\ascii_art.txt', [System.Convert]::FromBase64String((Get-Content \"%ENCODED_ASCII_ART%\" -Raw)))"
if errorlevel 1 (
    echo %RED%Failed to decode ASCII art file.%RESET%
    pause
    exit /b
)

:: Show ASCII art
type "%TEMP%\ascii_art.txt"

:: Warning about install path
echo %RED%Warning: Default installation path is:%RESET%
echo %RED%%DEFAULT_DEST_DIR%%RESET%
echo %RED%Ensure the path is correct before continuing.%RESET%

:: Menu
echo.
echo %GREEN%1. Activate%RESET%
echo %RED%2. Exit%RESET%
set /p choice=Choose an option (1 or 2): 

if "%choice%"=="1" (
    echo Verifying source file...
    if not exist "%TEMP%\decoded_file.txt" (
        echo %RED%Source file not found.%RESET%
        pause
        exit /b
    )
    echo %GREEN%Source file exists.%RESET%

    echo Verifying destination directory...
    if not exist "%DEFAULT_DEST_DIR%" (
        echo %RED%Destination directory not found. Please verify the path.%RESET%
        pause
        exit /b
    )
    echo %GREEN%Destination directory exists.%RESET%

    echo Terminating DriverBooster.exe if running...
    taskkill /F /IM DriverBooster.exe >nul 2>&1
    if errorlevel 1 (
        echo %RED%DriverBooster.exe not found or could not be terminated.%RESET%
    ) else (
        echo %GREEN%DriverBooster.exe process terminated.%RESET%
    )

    copy "%TEMP%\decoded_file.txt" "%DEFAULT_DEST_DIR%\version.dll" >nul
    if errorlevel 1 (
        echo %RED%Failed to copy file.%RESET%
    ) else (
        echo %GREEN%Activation successful!%RESET%
    )
    pause
) else if "%choice%"=="2" (
    echo Exiting...
    pause
    exit /b
) else (
    echo %RED%Invalid choice. Run again and choose 1 or 2.%RESET%
    pause
)

endlocal

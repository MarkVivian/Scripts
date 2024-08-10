@echo off

set /p script_name=Enter the script name: 

:: check if any file or input has been provided.
if "%script_name%" == "" (
    echo No command line argument provided.
    exit /b 1
 ) else (
    :: check if the file provided actually exists.
    if not exist "%script_name%" (
        echo File not found.
        exit /b 1
    ) else (
        :: run the script passed by %1 in admin powershell and change execution policy to unrestricted.

        REM powershell -Command "Start-Process Powershell -Verb RunAs -ExecutionPolicy Unrestricted -ArgumentList %script_name%"
    )    
 )



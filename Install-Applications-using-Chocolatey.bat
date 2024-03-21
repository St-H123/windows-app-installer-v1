@echo off
setlocal enabledelayedexpansion


REM CHECKING IF WE ARE RUNNING AS ADMINISTRATOR, AND RETURNING IF THIS IS NOT THE CASE.
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This batch file must be run as an administrator.
    echo Please right-click the batch file and select "Run as administrator".
    echo The application will now close.
    echo.
    pause
    exit /b 1
)

REM CHECKING IF CHOCOLATEY IS INSTALLED
where choco > nul 2>&1
if %errorlevel% equ 0 (
    echo Chocolatey is installed, proceeding
) else (
    echo Chocolatey is not installed, proceeding to install
    @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
    echo Chocolatey is installed, proceeding
)


REM CREATING THE VARIABLES THAT KEEP TRACK OF HOW MANY, AND WHAT COMMANDS FAILED.
set "errorCount=0"
set "failedCommands="
REM CREATING THE VARIABLE THAT WILL TRACK WHETHER OR NOT WE MUST BREAK THE LOOP
set "breakFlag="
REM CREATING THE VARIABLE THAT WILL STORE THE DIRECTORY THAT CONTAINS THE PATH TO THIS BATCH FILE
set "batchFilePath=%~dp0"


REM ASKING THE USERS PERMISSION FOR INSTALLING ALL THE APPLICATIONS
:input
echo We are about to try installing a bunch of applications.
echo Do you want to continue? (Y/N)
choice /c YN /n
if errorlevel 2 (
    echo You chose No.
    echo The application will now close.
    echo.
    pause
    exit /b 1
) else if errorlevel 1 (
    REM USER CHOSE YES, WE WILL NO PROCEED
    echo.
) else (
    echo Invalid input. Please enter either Y or N.
    goto input
)


REM LOOPING OVER THE COMMANDS IN "commands.txt" AND RUNNING THEM.
for /f "usebackq tokens=*" %%a in ("%batchFilePath%commands.txt") do (
    REM Check if we want to break out of the loop
    if defined breakFlag (
        REM If the breakFlag is defined, then we jump to the label "break"
        goto :break
    )
    REM DOING THE COMMAND IN THE "commands.txt" FILE.
    set "command=%%a"
    call %%a
    if errorlevel 1 (
        set /a "errorCount+=1"
        set "failedCommands=!failedCommands!, !command!"
    )
)
REM LABEL TO BREAK OUT OF THE LOOP IF NEEDED
:break


echo.
REM CHEKCING IF THERE WERE ERRORS, AND PRINTING THEM ONTO THE SCREEN.
if !errorCount! GTR 1 (
    REM WHEN THERE WERE MULTIPLE COMMANDS THAT FAILED
    echo There were !errorCount! errors while looping over the commands.
    echo Here are all the commands that failed: !failedCommands:~2!
    echo.
    echo The application will now close.
    echo.
    pause 
    exit /b 1
) else if !errorCount! GTR 0 (
    REM WHEN THERE WAS JUST ONE COMMAND THAT FAILED
    echo There was !errorCount! error while looping over the commands.
    echo This is the commands that failed: !failedCommands:~2!
    echo.
    echo The application will now close.
    echo.
    pause 
    exit /b 1
) else (
    REM WHEN DONE LOOPING OVER THE COMMANDS, WE PAUSE AND LET THE USER READ ALL THE ERROR MESSAGES.
    echo There were no errors while executing, everything went as expected!
    echo.
    echo The application will now close.
    echo.
    pause
    exit /b 0
)

@echo off
:: Check for administrator privileges
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"

:: Run PowerShell script as administrator
PowerShell Set-ExecutionPolicy Bypass
PowerShell Install-Module ps2exe
PowerShell Invoke-ps2exe -inputFile .\TeshsTool.ps1 -outputFile ..\TeshsTool.exe -noconsole -requireAdmin -version '2.0.0' -iconFile '../Assets/AppIcon.ico' -company 'Seth Earnhardt' -product 'TeshsTool' -copyright 'Copyright (c) 2023 Seth Earnhardt' -x64
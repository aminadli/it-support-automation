@echo off
title Launching System Inventory...
:: =================================================================
:: Script Name: 8 get systeminfo.bat
:: Description: Executes the '8_get_system_info.ps1' PowerShell script.
:: Why: Automates the bypass of default PowerShell execution policies to allow
::      standalone execution of custom management scripts.
:: =================================================================

:: %~dp0 automatically detects the current folder path
set SCRIPT_PATH=%~dp0get_system_info.ps1

echo Detecting system information...

:: This runs PowerShell, bypasses the restriction, and finds the script automatically
powershell -ExecutionPolicy Bypass -File "%SCRIPT_PATH%"

echo.
echo Process Complete.
pause
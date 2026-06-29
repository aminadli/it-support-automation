@echo off
title Corporate Software Deployer
:: =================================================================
:: Script Name: 6 OFFICE SOFTWARE.bat
:: Description: Automates the installation of standard office software.
:: Logic: 
::  1. Uses Windows Package Manager (Winget) for silent installs.
::  2. If Winget fails, falls back to direct PowerShell downloads 
::     and silent MSI/EXE execution.
::  3. Generates a timestamped log file for audit/troubleshooting.
:: =================================================================

:: --- 1. ADMIN ELEVATION ---
:: This block ensures the script runs as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    powershell Start-Process -Verb RunAs -FilePath "cmd" -ArgumentList "/c cd /d \"%~dp0\" && \"%~f0\""
    exit /b
)

:: --- 2. INITIALIZATION ---
echo ===========================================
echo   STANDARD SOFTWARE DEPLOYMENT
echo ===========================================

:: Disable MSStore source to prevent "License Agreement" prompts
winget source remove msstore >nul 2>&1

:: Create a log file in the same directory as the script
set "logfile=%~dp0install_log_%date:~-4,2%%date:~-7,2%_%time:~0,2%%time:~3,2%.txt"
echo Deployment Started: %date% %time% > "%logfile%"

:: --- 3. INSTALLATION LIST ---
:: Syntax: call :install_app "Display Name" "Winget.ID"
call :install_app "Google Chrome" "Google.Chrome"
call :install_app "AnyDesk" "AnyDesk.AnyDesk"
call :install_app "7-Zip" "7zip.7zip"
call :install_app "WinRAR" "RARLab.WinRAR"
call :install_app "Adobe Reader" "Adobe.Acrobat.Reader.64-bit"

echo.
echo Deployment Completed! 
echo View log: %logfile%
pause
exit /b

:: =================================================================
:: INSTALLATION FUNCTION
:: =================================================================
:install_app
echo.
echo [CHECK] Looking for %~1...
winget list --id %~2 --exact >nul 2>&1
if %errorlevel% equ 0 (
    echo %~1 is already installed.
    echo %date% %time% - %~1 already present. >> "%logfile%"
    exit /b
)

echo [INSTALL] Attempting Winget install for %~1...
winget install --id %~2 --silent --accept-package-agreements --accept-source-agreements >> "%logfile%" 2>&1

if %errorlevel% equ 0 (
    echo SUCCESS: %~1 installed via Winget.
    echo %date% %time% - %~1 installed via Winget. >> "%logfile%"
) else (
    echo WARNING: Winget failed for %~1. Attempting Fallback...
    echo %date% %time% - Winget failed for %~1. Starting Fallback. >> "%logfile%"
    
    :: Logic to decide which fallback to run
    if "%~1"=="Google Chrome" call :chrome_fallback
    if "%~1"=="AnyDesk" call :anydesk_fallback
)
exit /b

:: =================================================================
:: FALLBACK METHODS (Direct Download + Silent Install)
:: =================================================================

:chrome_fallback
set "url=https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi"
set "installer=%temp%\chrome_setup.msi"
echo Downloading Chrome MSI...
powershell -Command "Invoke-WebRequest -Uri '%url%' -OutFile '%installer%'"
start /wait msiexec /i "%installer%" /qn
if %errorlevel% equ 0 (echo Chrome Fallback Success!) else (echo Chrome Fallback Failed.)
del "%installer%" >nul 2>&1
exit /b

:anydesk_fallback
set "url=https://download.anydesk.com/AnyDesk.exe"
set "installer=%temp%\AnyDesk.exe"
echo Downloading AnyDesk...
powershell -Command "Invoke-WebRequest -Uri '%url%' -OutFile '%installer%'"
start /wait "" "%installer%" --install "%ProgramFiles(x86)%\AnyDesk" --silent
if %errorlevel% equ 0 (echo AnyDesk Fallback Success!) else (echo AnyDesk Fallback Failed.)
del "%installer%" >nul 2>&1
exit /b
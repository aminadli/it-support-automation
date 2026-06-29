@echo off
title PC Setup Master Launcher
:: ==========================================================================
:: Script Name: 000-Master-Setup.bat
:: Description: Self-elevating launcher for the PowerShell Master Menu.
:: Why: Bypasses execution policies and ensures the toolkit runs as Admin.
:: ==========================================================================

:: 1. CHECK FOR ADMIN RIGHTS
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [SYSTEM] Requesting Administrative Privileges...
    :: Re-runs this batch file as Administrator
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: 2. RUN THE MASTER SCRIPT
:: Ensure we are in the correct folder after elevation
cd /d "%~dp0"

echo [SYSTEM] Launching Master UI...
powershell -NoProfile -ExecutionPolicy Bypass -File "000-Master-Setup.ps1"

pause
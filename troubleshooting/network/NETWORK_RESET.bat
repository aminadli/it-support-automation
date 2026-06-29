@echo off
title Network & WiFi Repair Tool
:: ==========================================================================
:: Script Name: NETWORK_RESET.bat
:: Description: Self-elevating launcher for the Network Repair Utility.
:: Why: Automates the transition from CMD to a high-privilege PowerShell session.
:: ==========================================================================

:: CHECK FOR ADMIN RIGHTS
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [SYSTEM] Requesting Administrative Privileges...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: RUN THE REPAIR SCRIPT
cd /d "%~dp0"
echo [SYSTEM] Launching Network Optimization Utility...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "NETWORK_RESET.ps1"

pause
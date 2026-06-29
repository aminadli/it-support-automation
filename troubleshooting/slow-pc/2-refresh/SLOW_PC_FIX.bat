@echo off
title System Performance Optimizer
:: ==========================================================================
:: Script Name: SLOW_PC_FIX.bat
:: Description: Self-elevating launcher for the Performance Fix Utility.
:: Why: Automates the transition to an Admin PowerShell session for deep cleaning.
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
echo [SYSTEM] Launching Performance Optimization Utility...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "SLOW_PC_FIX.ps1"

pause
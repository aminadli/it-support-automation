@echo off
title System Diagnostic
:: ==========================================================================
:: Script Name: DIAGNOSTIC_REPORT.bat
:: Description: Execute DIAGNOSTIC_REPORT.ps1 script
:: Why: diagnose pc condition to rule out root cause
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
@echo off
title Windows 11 WMIC Installer
:: =================================================================
:: Script Name: 1 wmic.bat
:: Description: Restores WMIC functionality on Windows 11.
:: Why: Win11 removed WMIC by default, which is needed for many
::      legacy management scripts and name-change commands.
:: =================================================================

:: --- CONFIGURATION ---
set FEATURE_NAME=WMIC~~~~

echo ===========================================
echo   WINDOWS 11 FEATURE TOOL: %FEATURE_NAME%
echo ===========================================
echo.
echo IMPORTANT: This script requires:
echo 1. Administrative Privileges (Right-click > Run as Admin)
echo 2. An active Internet Connection
echo.
pause

:: --- EXECUTION ---
echo [STEP 1/1] Installing %FEATURE_NAME%...
echo This may take a few minutes depending on your internet speed.
echo.

dism /online /add-capability /capabilityname:%FEATURE_NAME%

echo.
echo ===========================================
echo   PROCESS COMPLETE
echo ===========================================
echo Please review the DISM output above for "The operation completed successfully."
pause
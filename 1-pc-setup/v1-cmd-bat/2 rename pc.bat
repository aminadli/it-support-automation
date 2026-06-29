@echo off
title PC Rename Tool

:: =================================================================
:: Script Name: 2 rename pc.bat
:: Description: Quickly renames the local computer using WMIC.
:: Note: Requires WMIC feature to be installed on Windows 11.
:: =================================================================

:: --- CONFIGURATION ---
:: Change the value below to your desired PC name
set NEW_PC_NAME=DESKTOP-OFFICE-01

echo ===========================================
echo   COMPUTER RENAME TOOL
echo ===========================================
echo Current Name: %computername%
echo Target Name : %NEW_PC_NAME%
echo.
echo NOTE: You must run this as Administrator.
echo.
pause

:: --- EXECUTION (The Engine) ---
echo.
echo Attempting to rename %computername% to %NEW_PC_NAME%...

wmic computersystem where name="%computername%" call rename name="%NEW_PC_NAME%"

echo.
echo ===========================================
echo   PROCESS COMPLETE
echo ===========================================
echo IMPORTANT: You must RESTART the computer for the name to change.
echo.
pause
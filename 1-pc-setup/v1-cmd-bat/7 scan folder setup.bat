@echo off
title SMB Scan Folder Setup
:: =================================================================
:: Script Name: 7 scan folder setup.bat
:: Description: Creates a C:\SCAN folder and shares it over the network.
:: Use Case: Setting up SMB scanning for network printers/copiers.
:: =================================================================

:: --- CONFIGURATION ---
set FOLDER_PATH=C:\SCAN
set SHARE_NAME=SCAN
:: Change the user below to the specific user who needs access
set ACCESS_USER=Everyone

echo ===========================================
echo   SMB SCAN FOLDER AUTOMATION
echo ===========================================

:: 1. Create the folder
if not exist "%FOLDER_PATH%" (
    echo [1/3] Creating folder: %FOLDER_PATH%...
    mkdir "%FOLDER_PATH%"
    if %errorlevel% neq 0 (
        echo ERROR: Could not create folder. Check permissions.
        pause
        exit /b
    )
) else (
    echo [1/3] Folder %FOLDER_PATH% already exists. Skipping...
)

:: 2. Set Local NTFS Permissions (icacls)
echo [2/3] Setting local NTFS permissions for %ACCESS_USER%...
icacls "%FOLDER_PATH%" /grant %ACCESS_USER%:(OI)(CI)F /t
:: (OI)(CI)F means "Object Inherit, Container Inherit, Full Control"
if %errorlevel% equ 0 (echo OK: Local permissions set.) else (echo FAILED: Could not set local permissions.)

:: 3. Share the folder on the Network (net share)
echo [3/3] Sharing folder as "%SHARE_NAME%"...
net share %SHARE_NAME%="%FOLDER_PATH%" /grant:%ACCESS_USER%,FULL /remark:"Printer Scan Folder"
if %errorlevel% equ 0 (
    echo OK: Folder shared successfully.
) else (
    echo FAILED: Share creation failed. (Check if already shared)
)

echo.
echo ===========================================
echo   AUTOMATION COMPLETE
echo ===========================================
echo Network Path: \\%computername%\%SHARE_NAME%
echo.
pause
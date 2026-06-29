@echo off
title Vendor Account Cleanup
:: =================================================================
:: Script Name: 4 remove user account.bat
:: Description: Deletes the default local account created by the vendor.
:: Use Case: Run this AFTER creating your official IT/Staff accounts
::           to clean up the system and improve security.
:: =================================================================

:: --- CONFIGURATION ---
:: Set this to the name of the account the vendor created (e.g., user, Owner, Admin)
set TARGET_USER=user

echo ===========================================
echo   CLEANUP: REMOVING VENDOR ACCOUNT
echo ===========================================

:: 1. Check if the user exists first
net user %TARGET_USER% >nul 2>&1
if %errorlevel% neq 0 (
    echo [SKIP] User account "%TARGET_USER%" was not found on this PC.
    goto :end
)

:: 2. Confirm with the technician
echo Warning: You are about to PERMANENTLY delete the "%TARGET_USER%" account.
echo This will remove all files and settings associated with that name.
pause

:: 3. Delete the account
echo [PROCESS] Deleting user: %TARGET_USER%...
net user %TARGET_USER% /delete

if %errorlevel% equ 0 (
    echo SUCCESS: Account removed.
) else (
    echo ERROR: Could not delete account. (Is it currently logged in?)
)

:end
echo.
echo ===========================================
echo   CURRENT LOCAL USERS
echo ===========================================
net user
echo.
echo Script execution complete.
pause
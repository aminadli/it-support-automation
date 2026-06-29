@echo off
title Local Account Setup Tool
:: ==========================================================================
:: Script Name: 3 local user account.bat
:: Description: Creates local Admin & Staff accounts and assigns group memberships.
:: Why: Automates a repetitive manual process to reduce setup time and human error.
:: Note: This script must be run with Administrative privileges.
:: ==========================================================================

:: --- SETUP VARIABLES ---
:: Changing these names here will update the whole script automatically
set ADMIN_USER=IT_Admin
set ADMIN_PASS=P@ssword123!

set STAFF_USER=Staff_User
set STAFF_PASS=Staff123!

echo ===========================================
echo   NEW PC ACCOUNT SETUP: STARTING...
echo ===========================================

:: 1. Create the IT Admin Account
echo Creating Admin account: %ADMIN_USER%
net user %ADMIN_USER% %ADMIN_PASS% /add
net localgroup Administrators %ADMIN_USER% /add
echo OK: Admin account created.

echo.

:: 2. Create the Standard Staff Account
echo Creating Staff account: %STAFF_USER%
net user %STAFF_USER% %STAFF_PASS% /add
echo OK: Staff account created.

echo.

:: 3. Show the results to the tech
echo ===========================================
echo   VERIFYING ACCOUNTS
echo ===========================================
net user
echo.
echo Setup Complete! Please remember to change passwords on first login.
pause
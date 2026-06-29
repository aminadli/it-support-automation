@echo off
title Windows 11 System Configuration Tool
:: =================================================================
:: Script Name: 5 change window setting .bat
:: Description: Automates common L1 setup tasks for a corporate environment.
:: Includes: Security policies, Network Discovery, SMB 1.0, and RDP.
:: =================================================================

echo ===========================================
echo   STARTING SYSTEM CONFIGURATION...
echo ===========================================

:: --- SECTION 1: Power & Account Policies ---
echo [1] Configuring Account and Power Policies...

:: Disable Fast Startup (Prevents many "Shut down vs Restart" bugs)
powercfg /h off

:: Disable password expiry and lockout (Best for shared local accounts)
net accounts /maxpwage:unlimited
net accounts /lockoutthreshold:0
net accounts /lockoutduration:0

:: Remove "Change Password" from Ctrl+Alt+Del
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableChangePassword" /t REG_DWORD /d 1 /f
echo OK: Policies applied.

echo.

:: --- SECTION 2: Network Discovery & File Sharing ---
echo [2] Enabling Network Discovery and Sharing...

:: Open Firewalls
netsh advfirewall firewall set rule group="Network Discovery" new enable=yes
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes

:: Configure and Start Services
for %%s in (FDResPub SSDPSRV upnphost) do (
    sc config %%s start= auto
    sc start %%s
)
echo OK: Networking services configured.

echo.

:: --- SECTION 3: Legacy SMB Features ---
echo [3] Configuring Legacy SMB Support...
:: NOTE: Required for some legacy office printers/NAS devices.

dism /online /enable-feature /featurename:SMB1Protocol /all /norestart
dism /online /enable-feature /featurename:SMBDirect /norestart

:: Prevent Windows from automatically removing SMB 1.0
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "Smb1Autoremove" /t REG_DWORD /d 0 /f
echo OK: SMB features enabled.

echo.

:: --- SECTION 4: Remote Desktop (RDP) ---
echo [4] Enabling Remote Desktop...

:: Registry and Firewall
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v "fDenyTSConnections" /t REG_DWORD /d 0 /f
netsh advfirewall firewall set rule group="Remote Desktop" new enable=yes

:: Allow all standard users to RDP (standardizing remote support access)
net localgroup "Remote Desktop Users" Users /add
echo OK: RDP enabled for all users.

echo.
echo ===========================================
echo   ALL SETTINGS APPLIED
echo ===========================================
echo Please RESTART the computer for all registry changes to take effect.
pause
# ==============================================================================
# Script Name: 05_CREATE_USER.ps1 
# Description: Provisions local IT Admin and Standard Staff accounts.
# Why: Standardizes the local security model. It ensures the IT Admin account 
#      is available for maintenance while Staff accounts have standard access.
# Special Feature: Includes a Winlogon Registry patch to ensure local users 
#      remain visible on the login screen (fixes common Windows UI bugs).
# ==============================================================================

# --- 1. ADMIN PRIVILEGE CHECK ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrative privileges required. Please run via the Master Launcher."
    Pause
    exit
}

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "          USER ACCOUNT CREATION SYSTEM         " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# --- 2. IT ADMIN ACCOUNT (Management Account) ---
$ITName = "IT_Admin"
# Sanitized for GitHub: Replace with your actual secure baseline password
$ITPassPlain = "CHANGE_ME_SECURE_123!" 
$ITPassword = ConvertTo-SecureString $ITPassPlain -AsPlainText -Force

if (Get-LocalUser -Name $ITName -ErrorAction SilentlyContinue) {
    Write-Host "[!] Admin User '$ITName' already exists. Updating profile..." -ForegroundColor Yellow
    Set-LocalUser -Name $ITName -FullName "IT Support" -Description "Company Management Account"
} else {
    Write-Host "[+] Creating New Administrator: $ITName..." -ForegroundColor Cyan
    New-LocalUser -Name $ITName -Password $ITPassword -FullName "IT Support" -Description "Company Management Account"
    Add-LocalGroupMember -Group "Administrators" -Member $ITName
}
Enable-LocalUser -Name $ITName

Write-Host "-----------------------------------------------"

# --- 3. STANDARD USER ACCOUNT (Interactive Input) ---
Write-Host "Enter details for the Standard User account:" -ForegroundColor White

$StandardName = Read-Host "Enter Staff Username (e.g., A123)"
# Fallback logic to prevent script crashes on empty input
if ([string]::IsNullOrWhiteSpace($StandardName)) { 
    $StandardName = "TEMP-USER" 
    Write-Host " -> No name entered. Defaulting to: $StandardName" -ForegroundColor Yellow
}

$StandardPassPlain = Read-Host "Enter Password for $StandardName"
if ([string]::IsNullOrWhiteSpace($StandardPassPlain)) { 
    $StandardPassPlain = "Welcome123!" 
    Write-Host " -> No password entered. Defaulting to: Welcome123!" -ForegroundColor Yellow
}
$StandardPassword = ConvertTo-SecureString $StandardPassPlain -AsPlainText -Force

if (Get-LocalUser -Name $StandardName -ErrorAction SilentlyContinue) {
    Write-Host "[!] User '$StandardName' already exists. Synchronizing..." -ForegroundColor Yellow
    Set-LocalUser -Name $StandardName -FullName $StandardName -Description "Standard Staff User"
} else {
    Write-Host "[+] Creating New Staff Account: $StandardName..." -ForegroundColor Cyan
    New-LocalUser -Name $StandardName -Password $StandardPassword -FullName $StandardName -Description "Standard Staff User"
    Add-LocalGroupMember -Group "Users" -Member $StandardName
}
Enable-LocalUser -Name $StandardName

# --- 4. LOGIN SCREEN VISIBILITY PATCH ---
# This registry modification fixes a common Windows issue where local 
# accounts are hidden from the login screen if certain policies are active.
Write-Host "`n[+] Applying 'SpecialAccounts' Registry Patch..." -ForegroundColor Cyan
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"

if (-not (Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }

# Set DWord value to 1 to force account visibility
Set-ItemProperty -Path $RegPath -Name $ITName -Value 1 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path $RegPath -Name $StandardName -Value 1 -Type DWord -ErrorAction SilentlyContinue

Write-Host "`n===============================================" -ForegroundColor Cyan
Write-Host " SUCCESS: USER SETUP COMPLETE" -ForegroundColor Green
Write-Host " Admin Created: $ITName"
Write-Host " Staff Created: $StandardName"
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "[!] ACTION: Restart the PC to finalize Login Screen changes." -ForegroundColor Yellow
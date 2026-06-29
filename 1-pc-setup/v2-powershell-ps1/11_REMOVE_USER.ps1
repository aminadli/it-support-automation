# ==============================================================================
# Script Name: 11_REMOVE_USER.ps1
# Description: Interactive Local User Account Deletion Tool.
# Why: Post-provisioning cleanup to remove temporary vendor accounts (e.g., 
#      'user', 'Owner') and minimize the local attack surface.
# ==============================================================================

# --- 1. ADMIN PRIVILEGE CHECK ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrative privileges required. Please run via the Master Launcher."
    Pause
    exit
}

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "          LOCAL USER ACCOUNT CLEANUP           " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# --- 2. ACCOUNT DISCOVERY & CLASSIFICATION ---
# We use a regex to identify accounts that should NOT be deleted
$ProtectedPattern = "Administrator|Guest|DefaultAccount|WDAGUtilityAccount|IT_Admin|Public"
$AllUsers = Get-LocalUser

Write-Host "Discovery: Local accounts found on this system:" -ForegroundColor White
Write-Host "-----------------------------------------------"

foreach ($user in $AllUsers) {
    if ($user.Name -match $ProtectedPattern) {
        Write-Host " [SYSTEM/PROTECTED] $($user.Name)" -ForegroundColor Gray
    } else {
        # Highlight potential vendor/temporary accounts
        Write-Host " [DETECTED/REMOVE?] $($user.Name)" -ForegroundColor Yellow -BackgroundColor Black
    }
}
Write-Host "-----------------------------------------------"

# --- 3. TARGET SELECTION ---
Write-Host "`nEnter the EXACT name of the account to PERMANENTLY DELETE:" -ForegroundColor White
$TargetUser = Read-Host "Target Username"

# --- 4. SAFETY & VALIDATION LOGIC ---

# A. Handle empty input
if ([string]::IsNullOrWhiteSpace($TargetUser)) {
    Write-Host "[ABORT] No username entered. Operation cancelled." -ForegroundColor Gray
    return
}

# B. Prevent accidental deletion of management or system accounts
if ($TargetUser -match $ProtectedPattern) {
    Write-Host "`n[!] CRITICAL ERROR: '$TargetUser' is a protected system account." -ForegroundColor Red
    Write-Host "Access Denied: Cannot delete management or built-in Windows accounts." -ForegroundColor Red
    return
}

# C. Verify the user exists
if (Get-LocalUser -Name $TargetUser -ErrorAction SilentlyContinue) {
    
    # D. Final Confirmation Prompt
    Write-Host "`nWARNING: This will permanently delete '$TargetUser' and all user data." -ForegroundColor Red
    $Confirm = Read-Host "Are you sure? Type 'Y' to confirm"
    
    if ($Confirm -eq "Y" -or $Confirm -eq "y") {
        try {
            Write-Host "[+] Removing user '$TargetUser'..." -ForegroundColor Cyan
            Remove-LocalUser -Name $TargetUser -ErrorAction Stop
            Write-Host "SUCCESS: Account deleted successfully." -ForegroundColor Green
        } catch {
            Write-Host "`n[!] ERROR: Could not remove user." -ForegroundColor Red
            Write-Host "Reason: User may be currently logged in or locked by the system." -ForegroundColor Yellow
        }
    } else {
        Write-Host "[ABORT] User cancelled the operation." -ForegroundColor Yellow
    }
} else {
    Write-Host "[!] ERROR: User '$TargetUser' not found. Please check spelling." -ForegroundColor Red
}

Write-Host "`nVerification: Updated Account List" -ForegroundColor White
Get-LocalUser | Select-Object Name, Enabled, Description | Format-Table
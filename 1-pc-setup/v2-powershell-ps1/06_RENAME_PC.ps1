# ==========================================================================
# Script Name: 06_RENAME_PC.ps1
# Description: Standardizes the system hostname.
# Why: Standard Operating Procedure (SOP) requires a consistent naming 
#      convention to ensure assets are easily identifiable within 
#      Centralized Management Consoles and Security Platforms.
# ==========================================================================

# --- 1. ADMIN PRIVILEGE CHECK ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrative privileges required. Please run via the Master Launcher."
    Pause
    exit
}

$CurrentName = $env:COMPUTERNAME

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "          HOSTNAME STANDARDIZATION             " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Current PC Name: $CurrentName" -ForegroundColor Yellow

# --- 2. INTERACTIVE INPUT ---
$NewName = Read-Host "Enter New Hostname (e.g., DEPT-PC-01)"

# --- 3. VALIDATION LOGIC ---
# Check if the user just pressed Enter (empty)
if ([string]::IsNullOrWhiteSpace($NewName)) {
    Write-Host "[SKIP] No name entered. No changes made." -ForegroundColor Gray
    return
}

# Check if the name is the same as the current name
if ($NewName -eq $CurrentName) {
    Write-Host "[SKIP] New name matches current name. No action needed." -ForegroundColor Green
    return
}

# NetBIOS limit is 15 characters. Names longer than this can cause network issues.
if ($NewName.Length -gt 15) {
    Write-Warning "WARNING: Hostname '$NewName' is longer than 15 characters."
    Write-Warning "This may cause issues with legacy network protocols."
}

# --- 4. EXECUTION ---
try {
    Write-Host "[+] Renaming computer to: $NewName..." -ForegroundColor Cyan
    # -Force suppresses the 'Are you sure?' prompt
    # -ErrorAction Stop ensures we catch any failures (like illegal characters)
    Rename-Computer -NewName $NewName -Force -ErrorAction Stop
    
    Write-Host "`nSUCCESS: Hostname changed to $NewName." -ForegroundColor Green
    Write-Host "[!] ACTION: A RESTART is required for the new name to take effect." -ForegroundColor Yellow
} 
catch {
    Write-Host "`n[!] ERROR: Could not rename computer." -ForegroundColor Red
    Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "===============================================" -ForegroundColor Cyan
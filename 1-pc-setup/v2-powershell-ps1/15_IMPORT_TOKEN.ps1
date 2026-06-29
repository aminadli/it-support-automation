# ==============================================================================
# Script Name: 15_IMPORT_TOKEN.ps1
# Description: Imports Google Chrome Cloud Management Enrollment Token (.reg).
# Why: Ensures the device is correctly enrolled in the Google Admin Console
#      for centralized browser policy management and security auditing.
# ⚠️ CRITICAL ORDER OF OPERATIONS:
#    Hostname (Rename-PC) MUST be finalized before running this script. 
#    Enrolling before renaming can cause duplicate entries or sync errors 
#    within the Google Workspace Admin Console.
# ==============================================================================

# --- 1. CONFIGURATION ---
$ConfigDir = Join-Path $PSScriptRoot "CONFIG"
$TokenDir  = Join-Path $ConfigDir "REGISTRY"
$RegFile   = Join-Path $TokenDir "08_CHROME_TOKEN.reg"

# Registry path for verification
$RegPath   = "HKLM:\SOFTWARE\Policies\Google\Chrome"
$TokenName = "CloudManagementEnrollmentToken"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "      CHROME CLOUD MANAGEMENT ENROLLMENT       " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# --- 2. PRE-FLIGHT CHECKS ---

# A. Admin Check
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrative privileges required."
    Pause ; exit
}

# B. Hostname Warning (Operational Guardrail)
Write-Host "[!] VERIFY: Has the Computer Name been finalized?" -ForegroundColor Yellow
Write-Host "Current Hostname: $($env:COMPUTERNAME)" -ForegroundColor White
$Confirm = Read-Host "Proceed with Enrollment? (Y/N)"
if ($Confirm -ne "Y" -and $Confirm -ne "y") {
    Write-Host "[ABORT] Please rename the PC and restart before enrolling." -ForegroundColor Red
    Pause ; return
}

# C. File Existence Check
if (-not (Test-Path $RegFile)) {
    Write-Host "[ERROR] Enrollment file missing: $RegFile" -ForegroundColor Red
    Write-Host "Action: Place the corporate .reg file in the CONFIG\REGISTRY folder." -ForegroundColor Yellow
    Pause ; return
}

# --- 3. EXECUTION (The Engine) ---
Write-Host "`n[+] Importing Enrollment Token..." -ForegroundColor Yellow
# /s for Silent, -Wait to ensure it finishes before verification
$process = Start-Process regedit.exe -ArgumentList "/s", "`"$RegFile`"" -Wait -PassThru

# --- 4. VERIFICATION LOGIC (Trust but Verify) ---
Write-Host "[+] Verifying Registry state..." -ForegroundColor Yellow
Start-Sleep -Seconds 2 # Give registry a moment to update

if (Test-Path $RegPath) {
    $Value = Get-ItemProperty -Path $RegPath -Name $TokenName -ErrorAction SilentlyContinue
    if ($Value) {
        Write-Host "SUCCESS: Chrome Enrollment Token is active." -ForegroundColor Green
        # Mask the token for display (Only show last 4 chars for security)
        $RawToken = $Value.$TokenName
        $MaskedToken = "*" * ($RawToken.Length - 4) + $RawToken.Substring($RawToken.Length - 4)
        Write-Host "Token ID (Masked): $MaskedToken" -ForegroundColor Gray
    } else {
        Write-Host "FAILED: Registry folder exists but Token value is missing." -ForegroundColor Red
    }
} else {
    Write-Host "FAILED: Registry path was not created. Check file permissions." -ForegroundColor Red
}

Write-Host "===============================================" -ForegroundColor Cyan
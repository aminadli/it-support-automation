# ==============================================================================
# Script Name: 99_RESUME_UPDATE.ps1
# Description: Restores Windows Update functionality.
# Why: Reverses the suppression applied by the '01_PAUSE_UPDATE' script.
#      Ensures the device is fully patched and compliant before delivery 
#      to the end-user.
# ==============================================================================

# --- 1. ADMIN PRIVILEGE CHECK ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrative privileges required. Please run via the Master Launcher."
    Pause
    exit
}

$RegistryPath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "      RESTORING WINDOWS UPDATE SERVICES        " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# --- 2. REGISTRY CLEANUP ---
# Removing the pause flags allows Windows to check for updates immediately
Write-Host "[1/2] Removing Update Pause Registry Flags..." -ForegroundColor Yellow

$ValuesToRemove = @(
    "PauseUpdatesExpiryTime"
    "PauseFeatureUpdatesStartTime"
    "PauseQualityUpdatesStartTime"
    "PauseUpdatesStartTime"
)

foreach ($Value in $ValuesToRemove) {
    if (Get-ItemProperty -Path $RegistryPath -Name $Value -ErrorAction SilentlyContinue) {
        Remove-ItemProperty -Path $RegistryPath -Name $Value -ErrorAction SilentlyContinue
        Write-Host "  - Removed: $Value" -ForegroundColor Gray
    }
}

# --- 3. SERVICE ORCHESTRATION ---
Write-Host "`n[2/2] Restarting Windows Update Services..." -ForegroundColor Yellow

# Re-enable the Windows Update Service (wuauserv)
Set-Service -Name wuauserv -StartupType Automatic

# Start all required update-related services
$Services = @("wuauserv", "bits", "dosvc")
foreach ($Svc in $Services) {
    Write-Host "  - Starting: $Svc..." -ForegroundColor Gray
    Start-Service -Name $Svc -ErrorAction SilentlyContinue
}

# --- 4. VERIFICATION ---
Write-Host "`n===============================================" -ForegroundColor Cyan
Write-Host " SUCCESS: Windows Update has been resumed.     " -ForegroundColor Green
Write-Host " The system will now check for patches normally." -ForegroundColor White
Write-Host "===============================================" -ForegroundColor Cyan
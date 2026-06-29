# ==========================================================================
# Script Name: 01_PAUSE_UPDATE.ps1
# Description: Forcefully cancels pending updates and pauses the service.
# Why: Prevents background update processes from slowing down the initial 
#      PC provisioning and app deployment process.
# ==========================================================================

# --- 1. ADMIN PRIVILEGE CHECK ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrative privileges required. Please run via the Master Launcher."
    Pause
    exit
}

# --- 2. CONFIGURATION ---
$RegistryPath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
$TargetDate = (Get-Date).AddDays(7).ToString("yyyy-MM-ddTHH:mm:ssZ")
$CurrentDate = Get-Date

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "       WINDOWS UPDATE SUPPRESSION TOOL         " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# --- 3. PRE-CHECK ---
$CurrentPause = Get-ItemProperty -Path $RegistryPath -Name "PauseUpdatesExpiryTime" -ErrorAction SilentlyContinue
if ($CurrentPause -and ([datetime]$CurrentPause.PauseUpdatesExpiryTime -gt $CurrentDate)) {
    Write-Host "[INFO] Updates are already paused until $($CurrentPause.PauseUpdatesExpiryTime)." -ForegroundColor Cyan
}

# --- 4. THE 'NUKE' (Clearing Pending Tasks) ---
Write-Host "[1/3] Stopping Update Services & Processes..." -ForegroundColor Yellow

# Kill the Worker Process that handles active downloads/installs
Get-Process MoUsoCoreWorker -ErrorAction SilentlyContinue | Stop-Process -Force

# Stop the core Update Services
$Services = @("wuauserv", "bits", "dosvc", "cryptsvc")
foreach ($Service in $Services) {
    Stop-Service -Name $Service -Force -ErrorAction SilentlyContinue
}

# --- 5. CACHE CLEARING ---
Write-Host "[2/3] Clearing SoftwareDistribution cache..." -ForegroundColor Yellow
# Renaming the folder is a safer 'L2' method than deleting it immediately
$SDPath = "C:\Windows\SoftwareDistribution"
if (Test-Path $SDPath) {
    $OldPath = "$SDPath.old.$(Get-Date -Format 'yyyyMMddHHmm')"
    Rename-Item -Path $SDPath -NewName $OldPath -ErrorAction SilentlyContinue
    Write-Host " - Cache moved to $OldPath" -ForegroundColor Gray
}

# --- 6. REGISTRY PAUSE ---
Write-Host "[3/3] Applying 7-day pause to Registry..." -ForegroundColor Yellow
if (-not (Test-Path $RegistryPath)) { New-Item -Path $RegistryPath -Force | Out-Null }

$RegistryValues = @{
    "PauseUpdatesExpiryTime"        = $TargetDate
    "PauseFeatureUpdatesStartTime"  = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    "PauseQualityUpdatesStartTime"  = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    "PauseUpdatesStartTime"         = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
}

foreach ($Name in $RegistryValues.Keys) {
    Set-ItemProperty -Path $RegistryPath -Name $Name -Value $RegistryValues[$Name] -Force
}

# --- 7. CLEANUP ---
Start-Service -Name cryptsvc -ErrorAction SilentlyContinue
Write-Host "`nSUCCESS: Windows Update suppressed until $TargetDate." -ForegroundColor White -BackgroundColor DarkGreen
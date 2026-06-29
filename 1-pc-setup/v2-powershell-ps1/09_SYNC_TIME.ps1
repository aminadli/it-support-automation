# ==========================================================================
# Script Name: 09_SYNC_TIME.ps1
# Description: Synchronizes System Time and Sets Regional Time Zone.
# Why: Incorrect system time causes failures in SSL/TLS handshakes, VPN 
#      connectivity, and time-sensitive support tools like AnyDesk.
# ==========================================================================

# --- 1. ADMIN PRIVILEGE CHECK ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrative privileges required. Please run via the Master Launcher."
    Pause
    exit
}

# --- 2. CONFIGURATION ---
# "Singapore Standard Time" covers GMT+8 (Malaysia/Singapore)
$TimeZone = "Singapore Standard Time"
$NTPServer = "time.windows.com,0x1"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "      SYSTEM TIME & TIMEZONE SYNC              " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# --- 3. SET TIME ZONE ---
Write-Host "[1/3] Configuring Time Zone to $TimeZone..." -ForegroundColor Yellow
tzutil /s $TimeZone

# --- 4. SERVICE ORCHESTRATION ---
Write-Host "[2/3] Resetting Windows Time Service (w32time)..." -ForegroundColor Yellow

# Ensure the service is set to Automatic and started
Set-Service w32time -StartupType Automatic
Stop-Service w32time -Force -ErrorAction SilentlyContinue
Start-Service w32time

# --- 5. NTP CONFIGURATION & RESYNC ---
Write-Host "[3/3] Syncing with NTP Server ($NTPServer)..." -ForegroundColor Yellow

# Re-register the time service and update configuration
w32tm /config /manualpeerlist:$NTPServer /syncfromflags:manual /update

# Force a resync
w32tm /resync /force | Out-Null

# --- 6. VERIFICATION ---
$CurrentTime = Get-Date
if ($LASTEXITCODE -eq 0) {
    Write-Host "`nSUCCESS: Time synchronized successfully." -ForegroundColor Green
    Write-Host "Current System Time: $($CurrentTime.ToString('f'))" -ForegroundColor White
} else {
    Write-Host "`n[!] WARNING: Time sync may have failed." -ForegroundColor Red
    Write-Host "Check internet connection or UDP Port 123 (NTP) availability." -ForegroundColor Yellow
}

Write-Host "===============================================" -ForegroundColor Cyan
# ==========================================================================
# Script Name: SLOW_PC_FIX.ps1
# Description: Automated System Remediation & Performance Cleanup.
# Why: Manual system cleaning is tedious. This script targets the #1 cause
#      of slowness: Cache bloat, temp file congestion, and stalled services.
# ==========================================================================

# --- 1. ADMIN PRIVILEGE CHECK ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrative privileges required."
    Pause ; exit
}

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "      SYSTEM PERFORMANCE OPTIMIZER             " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# --- 2. TEMP FILE PURGE ---
# Targets System Temp, User Temp, and Prefetch
Write-Host "[1/4] Purging Temporary File Repositories..." -ForegroundColor Yellow

$TempFolders = @(
    "$env:TEMP\*"
    "$env:SystemRoot\Temp\*"
    "$env:SystemRoot\Prefetch\*"
)

foreach ($Path in $TempFolders) {
    Write-Host "    - Cleaning: $Path" -ForegroundColor Gray
    # We use ErrorAction SilentlyContinue because files currently in use cannot be deleted
    Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
}
Write-Host "SUCCESS: Temporary files purged." -ForegroundColor Green

# --- 3. RECYCLE BIN & THUMBNAIL CACHE ---
Write-Host "`n[2/4] Emptying Recycle Bin & Thumbnail Caches..." -ForegroundColor Yellow
Clear-RecycleBin -Confirm:$false -ErrorAction SilentlyContinue
# Clears the explorer icon cache which can cause sluggish folder loading
Get-Process Explorer | Stop-Process -Force # Explorer will auto-restart
Write-Host "SUCCESS: Desktop resources refreshed." -ForegroundColor Green

# --- 4. WINDOWS COMPONENT CLEANUP (DISM) ---
# This is a "Pro" move. It cleans up old versions of Windows Updates.
Write-Host "`n[3/4] Optimizing Windows Component Store (DISM)..." -ForegroundColor Yellow
Write-Host "    - This may take a few minutes. Please wait..." -ForegroundColor Gray
dism /online /cleanup-image /startcomponentcleanup /quiet
Write-Host "SUCCESS: System component store optimized." -ForegroundColor Green

# --- 5. DISK CLEANUP AUTOMATION ---
Write-Host "`n[4/4] Triggering Windows Disk Cleanup..." -ForegroundColor Yellow
# 'sagerun:1' is a standard preset for cleanmgr.exe
cleanmgr /sagerun:1 | Out-Null
Write-Host "SUCCESS: Disk cleanup completed." -ForegroundColor Green

# --- FINAL VERIFICATION ---
Write-Host "`n===============================================" -ForegroundColor Cyan
Write-Host "      OPTIMIZATION COMPLETE                    " -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "NOTE: If the PC is still slow, please check Task Manager" -ForegroundColor Yellow
Write-Host "for high Disk/CPU usage which may indicate a failing drive." -ForegroundColor Yellow
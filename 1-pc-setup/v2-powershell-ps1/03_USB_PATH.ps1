# ==========================================================================
# Script Name: 03_USB_PATH.ps1
# Description: Moves the current USB drive letter to Z:
# Why: Standard Operating Procedure (SOP) requires local disk partitioning 
#      to use the D: drive. This script prevents the USB from "squatting" 
#      on the D: letter, ensuring local partitions are correctly assigned.
# ==========================================================================

# --- 1. IDENTIFY CURRENT LOCATION ---
# Grabs the first character of the path where the script is running (e.g., "D")
$CurrentLetter = $PSScriptRoot.Substring(0,1) 
$TargetLetter = "Z"

if ($CurrentLetter -eq $TargetLetter) {
    Write-Host "[INFO] USB is already assigned to ${TargetLetter}:. Skipping." -ForegroundColor Green
    Start-Sleep -Seconds 2
    return
}

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "        USB DRIVE RELOCATION TOOL              " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Current Letter: ${CurrentLetter}:"
Write-Host "Target Letter : ${TargetLetter}:"
Write-Host ""
Write-Host "[!] Logic: Handing off task to C:\Temp to unlock USB drive..." -ForegroundColor Yellow

# --- 2. CREATE DISKPART INSTRUCTIONS ---
# We save this to the local TEMP folder (usually on C:)
$DiskpartScript = @"
select volume $CurrentLetter
assign letter=$TargetLetter
"@
$DiskpartPath = "$env:TEMP\usb_swap.txt"
$DiskpartScript | Out-File -FilePath $DiskpartPath -Encoding ASCII

# --- 3. CREATE BACKGROUND LAUNCHER ---
# Because this script is RUNNING from the USB, we cannot rename the USB yet.
# We create a temporary batch file on the C: drive to do the work after 
# this PowerShell process closes.
$BatchContent = @"
@echo off
:: Wait 2 seconds for PowerShell to fully exit
timeout /t 2 /nobreak > nul
diskpart /s "$DiskpartPath"
del "$DiskpartPath"
del "%~f0"
"@
$BatchPath = "$env:TEMP\usb_mover.bat"
$BatchContent | Out-File -FilePath $BatchPath -Encoding ASCII

# --- 4. EXECUTION & SELF-TERMINATION ---
# Launch the batch file as a separate, hidden process
Start-Process "cmd.exe" -ArgumentList "/c $BatchPath" -WindowStyle Hidden

Write-Host "Swapping drive letter now. Master Menu will close." -ForegroundColor Green
Write-Host "Please re-launch the toolkit from Z:\ after 2 seconds." -ForegroundColor White

# IMMEDIATELY KILL the PowerShell process to release the file handle on the USB
Stop-Process -Id $PID
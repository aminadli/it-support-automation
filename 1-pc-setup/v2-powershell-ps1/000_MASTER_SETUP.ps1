# ==========================================================================
# Script Name: 000-Master-Setup.ps1
# Description: Interactive Menu for Automated PC Provisioning.
# Why: Provides a single interface for technicians to execute specific tasks.
# ==========================================================================

$ScriptDir = $PSScriptRoot

function Show-Menu {
    Clear-Host
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "           NEW PC SETUP MASTER MENU            " -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host " 1.  PAUSE WINDOWS UPDATES"
    Write-Host " 3.  CHANGE USB DRIVE PATH"
    Write-Host " 4.  DISK PARTITIONING"
    Write-Host " 5.  LOCAL ACCOUNT SETUP"
    Write-Host " 6.  RENAME COMPUTER"
    Write-Host " 7.  OPTIMIZE WINDOWS SETTINGS"
    Write-Host " 8.  UNINSTALL BLOATWARE"
    Write-Host " 9.  SYNC SYSTEM TIME"
    Write-Host " 11. DELETE VENDOR ACCOUNT"
    Write-Host " 14. INSTALL STANDARD SOFTWARE"
    Write-Host " 15. IMPORT SECURITY TOKENS"
    Write-Host " 16. PULL SYSTEM INVENTORY"
    Write-Host " 99. RESUME WINDOWS UPDATES"
    Write-Host "-----------------------------------------------"
    Write-Host " L.  [LOGOUT]   Sign Out Current User" -ForegroundColor Gray
    Write-Host " R.  [RESTART]  Restart (Skip Updates)" -ForegroundColor Yellow
    Write-Host " S.  [SHUTDOWN] Shutdown (Skip Updates)" -ForegroundColor Red
    Write-Host " Q.  [QUIT]     Exit Toolkit" -ForegroundColor White
    Write-Host "==============================================="
}

do {
    Show-Menu
    $choice = Read-Host "Enter Option Number"

    # Convert choice to lowercase to handle 'L' vs 'l'
    switch ($choice.ToLower()) {
        '1'  { & "$ScriptDir\01_PAUSE_UPDATE.ps1" }
        '3'  { & "$ScriptDir\03_USB_PATH.ps1" }
        '4'  { & "$ScriptDir\04_PARTITION.ps1" } 
        '5'  { & "$ScriptDir\05_CREATE_USER.ps1" }
        '6'  { & "$ScriptDir\06_RENAME_PC.ps1" }
        '7'  { & "$ScriptDir\07_WINDOW_SETTING.ps1" }
        '8'  { & "$ScriptDir\08_UNINSTALL_APP.ps1" }
        '9'  { & "$ScriptDir\09_SYNC_TIME.ps1" }
        '11' { & "$ScriptDir\11_REMOVE_USER.ps1" }
        '14' { & "$ScriptDir\14_SOFTWARE_INSTALL.ps1" }
        '15' { & "$ScriptDir\15_IMPORT_TOKEN.ps1" }
        '16' { & "$ScriptDir\16_SPEC.ps1" }
        '99' { & "$ScriptDir\99_RESUME_UPDATE.ps1" }

        'l' { 
            Write-Host "Signing out..." -ForegroundColor Gray
            shutdown.exe /l 
        }
        'r' { 
            Write-Host "Restarting..." -ForegroundColor Yellow
            shutdown.exe /r /f /t 0 
        }
        's' { 
            Write-Host "Shutting down..." -ForegroundColor Red
            shutdown.exe /s /f /t 0 
        }
        'q' { return }
        
        Default {
            Write-Host "Invalid selection, please try again." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
    
    # Pause to allow tech to see the result of the task
    if ($choice -notmatch '[lrs q]') {
        Write-Host "`nTask Complete. Press Enter to return to menu..." -ForegroundColor Gray
        Read-Host
    }

} while ($choice -ne 'q')
# ==============================================================================
# Script Name: 08_UNINSTALL_APP.ps1
# Description: Professional Endpoint Debloat & Bloatware Removal Tool.
# Why: Standardizes the OS environment by removing non-essential manufacturer 
#      software and telemetry agents. This optimizes disk space, reduces 
#      background resource consumption, and minimizes the attack surface.
# ==============================================================================

# --- 1. CONFIGURATION: TARGET LISTS ---

# A. Universal Appx Packages (Microsoft Store / UWP Apps)
# To keep an app, simply add a '#' at the start of the line to comment it out.
$AppxTargets = @(
    "Copilot"              # Microsoft AI Integration
    "OneDrive"             # Microsoft Cloud Storage (Stub)
    "Teams"                # Consumer Microsoft Teams
    "Outlook"              # "New" Outlook Preview stub
    "Solitaire"            # Microsoft Casual Games
    "Xbox"                 # Xbox Game Bar and Services
    "Maps"                 # Windows Maps
    "Weather"              # Weather and News
    "YourPhone"            # Phone Link / Mobile integration
    "HPDocumentation"      # HP PDF Manuals
    "HPNotifications"      # HP Marketing/Support popups
    "HPJumpStarts"         # HP Welcome/Onboarding
    "HPSystemEventUtility" # HP Shortcut keys support
    "HPPrivacySettings"    # HP Privacy setup tool
)

# B. Standard Win32 Desktop Programs (MSI/EXE)
$Win32Targets = @(
    "HP Support Assistant"            
    "HP Connection Optimizer"         
    "HP Client Optimizer"             
    "HP Audio Switch"                 
    "HP Support Solutions Framework"  
    "HP Documentation"                
)

# C. Security Agent Sequence (Strict Removal Order)
$SecurityAgentOrder = @(
    "HP Wolf Security(?!.*Console)"   # 1. Core Agent
    "HP Wolf Security.*Console"       # 2. Management Console
    "HP Security Update Service"      # 3. Background Updater
)

# --- 2. HELPER FUNCTIONS ---

function Remove-AppxGroup {
    param([string[]]$AppList)
    $Regex = ($AppList -join "|")
    Write-Host "[+] Processing Universal Appx Packages..." -ForegroundColor Yellow
    
    # Remove from current user session
    Get-AppxPackage -AllUsers | Where-Object { $_.Name -match $Regex } | ForEach-Object {
        try { 
            Write-Host "    - Uninstalling: $($_.Name)" -ForegroundColor Gray
            $_ | Remove-AppxPackage -AllUsers -ErrorAction Stop 
        } catch { Write-Host "    - [!] Skipped: $($_.Name) (System Protected)" -ForegroundColor DarkGray }
    }
    
    # Remove from 'Provisioned' list (Prevents app from reinstalling on new user login)
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -match $Regex } | ForEach-Object {
        try { Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue } catch {}
    }
}

function Uninstall-Win32Program {
    param([string]$DisplayName)
    $RegPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    
    $Program = Get-ItemProperty $RegPaths | Where-Object { $_.DisplayName -match $DisplayName } | Select-Object -First 1
    
    if ($Program.UninstallString) {
        Write-Host "    - Removing Program: $($Program.DisplayName)" -ForegroundColor Cyan
        $Uninstaller = $Program.UninstallString

        if ($Uninstaller -match "msiexec") {
            # Convert /I (Install) to /X (Uninstall) and add Silent flags
            $Args = $Uninstaller -replace "msiexec.exe", "" -replace "/I", "/X"
            $Args += " /qn /norestart"
            Start-Process msiexec.exe -ArgumentList $Args -Wait -NoNewWindow
        } else {
            # Execute standard uninstaller with common silent switches
            Start-Process cmd.exe -ArgumentList "/c $Uninstaller /S /silent /verysilent" -Wait -NoNewWindow
        }
    }
}

# --- 3. EXECUTION ROUTINE ---

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "        ENDPOINT DEBLOAT & OPTIMIZATION        " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Step 1: Clean Appx Store Packages
Remove-AppxGroup -AppList $AppxTargets

# Step 2: Sequential Security Agent Removal
Write-Host "`n[+] Removing Manufacturer Security Stack..." -ForegroundColor Yellow
foreach ($Pattern in $SecurityAgentOrder) { Uninstall-Win32Program -DisplayName $Pattern }

# Step 3: Clean Win32 Bloatware
Write-Host "`n[+] Removing Manufacturer Desktop Software..." -ForegroundColor Yellow
foreach ($Name in $Win32Targets) { Uninstall-Win32Program -DisplayName $Name }

# Step 4: Forceful OneDrive Cleanup
$OneDrivePath = if (Test-Path "$env:SystemRoot\SysWOW64\OneDriveSetup.exe") { "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" } else { "$env:SystemRoot\System32\OneDriveSetup.exe" }
if (Test-Path $OneDrivePath) {
    Write-Host "`n[+] Finalizing OneDrive Removal..." -ForegroundColor Yellow
    Start-Process $OneDrivePath -ArgumentList "/uninstall" -Wait -NoNewWindow -ErrorAction SilentlyContinue
}

# Step 5: Residual Service Management
Write-Host "`n[+] Disabling residual manufacturer background services..." -ForegroundColor Yellow
$ResidualServices = Get-Service | Where-Object { $_.DisplayName -match "HP " -or $_.Name -match "HP" }
foreach ($Svc in $ResidualServices) {
    Write-Host "    - Disabling Service: $($Svc.Name)" -ForegroundColor Gray
    Stop-Service $Svc.Name -Force -ErrorAction SilentlyContinue
    Set-Service $Svc.Name -StartupType Disabled -ErrorAction SilentlyContinue
}

Write-Host "`n===============================================" -ForegroundColor Cyan
Write-Host "       DEBLOAT TASKS COMPLETED SUCCESSFULLY    " -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Cyan
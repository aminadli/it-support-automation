# ==============================================================================
# Script Name: 14_SOFTWARE_INSTALL.ps1
# Description: Automated Modular Software Deployment Framework.
# Why: Standardizes software baselines across different departments (HQ, Branch, 
#      VPN Users) using a "Blueprint" architecture.
# Features: Silent MSI/EXE deployment, custom Post-Install logic, and 
#           automated VPN profile injection.
# ==============================================================================

# --- 1. GLOBAL CONFIGURATION ---
$Repo = [PSCustomObject]@{
    AppsDir      = Join-Path $PSScriptRoot "SOFTWARE"
    ConfigDir    = Join-Path $PSScriptRoot "CONFIG"
    # Placeholder passwords for GitHub - Ensure real passwords are never committed
    AnyDeskPass  = "SECURE_PASSWORD_HERE"  
    FortiPass    = "SECURE_PASSWORD_HERE"
}

$Paths = @{
    FortiCfg  = Join-Path $Repo.ConfigDir "FORTICLIENT"
    SmartVPN  = Join-Path $Repo.ConfigDir "SMARTVPN"
}

# ==============================================================================
# 2. THE BLUEPRINTS (Master Software Pool)
# ==============================================================================
# This array defines how each application is handled. 
# PostInstall blocks allow for advanced automation (Registry fixes, Shortcuts, etc.)
$SoftwarePool = @(
    [PSCustomObject]@{
        ID    = 1
        Name  = "Google Chrome"
        File  = "01CHROME.exe"
        Args  = "/silent /install"
        Check = "C:\Program Files\Google\Chrome\Application\chrome.exe"
        PostInstall = { Create-PublicShortcut "Google Chrome" $Target.Check }
    }
    [PSCustomObject]@{
        ID    = 3
        Name  = "AnyDesk"
        File  = "03ANYDESK.exe"
        Args  = '--install "C:\Program Files\AnyDesk" --silent --start-with-win'
        Check = "C:\Program Files\AnyDesk\AnyDesk.exe"
        PostInstall = {
            Start-Sleep -Seconds 5
            echo $Repo.AnyDeskPass | & $Target.Check --set-password
            Create-PublicShortcut "AnyDesk" $Target.Check
        }
    }
    [PSCustomObject]@{
        ID    = 6
        Name  = "DrayTek SmartVPN"
        File  = "06SMARTVPN.exe"
        Args  = "/S"
        Check = "C:\Program Files (x86)\DrayTek\Smart VPN Client\SmartVPNClient.exe"
        PostInstall = {
            $InstallDir = "C:\Program Files (x86)\DrayTek\Smart VPN Client"
            
            # Logic: Import VPN Profile (.cfg) from local repository
            $CfgFile = Get-ChildItem -Path $Paths.SmartVPN -Filter "*.cfg" | Select-Object -First 1
            if ($CfgFile) {
                Copy-Item -Path $CfgFile.FullName -Destination "$InstallDir\SmartVPN.cfg" -Force
            }

            # Logic: Registry Patch to support L2TP without IPsec enforcement
            $RegPath = "HKLM:\System\CurrentControlSet\Services\RasMan\Parameters"
            Set-ItemProperty -Path $RegPath -Name "ProhibitIpSec" -Value 1 -Type DWord
        }
    }
    [PSCustomObject]@{
        ID    = 10
        Name  = "FortiClient VPN"
        File  = "10FORTI.exe"           
        Args  = "/quiet /norestart"     
        Check = "C:\Program Files\Fortinet\FortiClient\FortiClient.exe"
        PostInstall = {
            # Logic: Automated Profile Import via FortiClient CLI
            $Cfg = Get-ChildItem -Path $Paths.FortiCfg -Include *.conf, *.xml -Recurse | Select-Object -First 1
            if ($Cfg) {
                Start-Sleep -Seconds 10
                & "C:\Program Files\Fortinet\FortiClient\FCConfig.exe" -o import -f "$($Cfg.FullName)" -p $Repo.FortiPass
            }
        }
    }
)

# Preset Profiles for Rapid Deployment
$Pkg_HQ         = @(1, 3, 10)
$Pkg_Branch     = @(1, 3, 6)

# ==============================================================================
# 3. HELPER FUNCTIONS
# ==============================================================================
function Create-PublicShortcut {
    param($Name, $TargetPath)
    try {
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut("$env:PUBLIC\Desktop\$Name.lnk")
        $Shortcut.TargetPath = $TargetPath
        $Shortcut.Save()
    } catch { Write-Warning "Shortcut creation failed for $Name" }
}

# ==============================================================================
# 4. THE ENGINE (Execution Loop)
# ==============================================================================

# [Menu Logic omitted for brevity - Keep your existing menu code here]

foreach ($Target in $Selection) {
    # 1. Check if software is already installed to prevent duplicate work
    if ($Target.Check -and (Test-Path $Target.Check)) {
        Write-Host "[SKIP] $($Target.Name) already present." -ForegroundColor Gray
        continue
    }

    # 2. Path & Argument Processing
    $ExePath = if ($Target.File -eq "msiexec.exe") { "msiexec.exe" } else { Join-Path $Repo.AppsDir $Target.File }
    $ActualArgs = if ($Target.Args -is [scriptblock]) { & $Target.Args } else { $Target.Args }

    # 3. Execution
    Write-Host "[+] Deploying: $($Target.Name)..." -ForegroundColor Yellow
    if (Test-Path $ExePath) {
        $Process = Start-Process -FilePath $ExePath -ArgumentList $ActualArgs -Wait -NoNewWindow -PassThru
        
        # 4. Custom Post-Install Automation
        if ($Target.PostInstall -is [scriptblock]) {
            Write-Host "    [*] Running Post-Install Tasks..." -ForegroundColor Gray
            & $Target.PostInstall
        }
    }
}
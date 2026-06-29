# ==========================================================================
# Script Name: NETWORK_RESET.ps1
# Description: Performs a comprehensive Network Stack Reset and WiFi Optimization.
# Why: Manual network resets are time-consuming and often miss deep driver-level 
#      settings (Power Management/Roaming) that cause intermittent WiFi drops.
# ==========================================================================

# --- 1. ADMIN PRIVILEGE CHECK ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrative privileges required."
    Pause ; exit
}

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "      NETWORK & WIFI REPAIR UTILITY            " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# --- 2. NETWORK STACK RESET ---
# This clears the "pipes" of the internet connection.
Write-Host "[1/3] Resetting TCP/IP Stack & Flushing DNS..." -ForegroundColor Yellow

$Commands = @(
    "netsh winsock reset"
    "netsh int ip reset"
    "ipconfig /release"
    "ipconfig /flushdns"
    "ipconfig /renew"
)

foreach ($Cmd in $Commands) {
    Write-Host "    - Executing: $Cmd" -ForegroundColor Gray
    Invoke-Expression $Cmd | Out-Null
}
Write-Host "SUCCESS: Network stack has been refreshed." -ForegroundColor Green

# --- 3. WIFI DRIVER OPTIMIZATION ---
# This targets physical WiFi adapters to fix "Sleep" and "Roaming" issues.
Write-Host "`n[2/3] Optimizing WiFi Adapter Registry Settings..." -ForegroundColor Yellow

$Adapters = Get-CimInstance -ClassName Win32_NetworkAdapter | Where-Object { 
    $_.AdapterTypeId -eq 0 -and 
    ($_.Name -match "Wi-Fi|Wireless") -and
    $_.Name -notmatch "Virtual|Pseudo|Direct"
}

foreach ($Adapter in $Adapters) {
    # Match the DeviceID to the registry path format (e.g., 0001)
    $RegID = ($Adapter.DeviceID).PadLeft(4,'0')
    $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\$RegID"
    
    if (Test-Path $RegPath) {
        Write-Host "    - Processing: $($Adapter.Name)" -ForegroundColor White
        
        # PnPCapabilities = 24 (0x18) disables "Allow computer to turn off device to save power"
        # This fixes the common "No WiFi after Sleep" issue.
        Set-ItemProperty -Path $RegPath -Name "PnPCapabilities" -Value 24 -ErrorAction SilentlyContinue
        
        # RoamingAggressiveness = 1 (Lowest) prevents the PC from jumping between Access Points 
        # too frequently in an office environment.
        Set-ItemProperty -Path $RegPath -Name "RoamingAggressiveness" -Value "1" -ErrorAction SilentlyContinue 
        
        # MimoPowerSaveMode = 0 (Disabled) ensures maximum throughput.
        Set-ItemProperty -Path $RegPath -Name "MimoPowerSaveMode" -Value "0" -ErrorAction SilentlyContinue
    }
}
Write-Host "SUCCESS: Hardware power and roaming optimizations applied." -ForegroundColor Green

# --- 4. REBOOT SEQUENCE ---
Write-Host "`n[3/3] Repair Complete. System must restart to finalize." -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

for ($i = 10; $i -gt 0; $i--) {
    Write-Host -NoNewline "`rSystem will restart in $i seconds... (Ctrl+C to Cancel) " -ForegroundColor Red
    Start-Sleep -Seconds 1
}

Restart-Computer -Force
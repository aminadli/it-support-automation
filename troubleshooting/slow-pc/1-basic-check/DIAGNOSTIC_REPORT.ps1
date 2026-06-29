# ==============================================================================
# Script Name: DIAGNOSTIC_REPORT.ps1
# Description: Full System Hardware & Health Audit.
# Why: Used as the first step in troubleshooting. Helps identify if an issue 
#      is caused by hardware limitations (low RAM), high uptime (needs restart), 
#      or need deep dive.
# ==============================================================================

# --- 1. ADMIN PRIVILEGE CHECK ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrative privileges required for full hardware access."
    Pause ; exit
}

Clear-Host
$PCName = $env:COMPUTERNAME
$OS = Get-CimInstance Win32_OperatingSystem
$Uptime = (Get-Date) - $OS.LastBootUpTime
$UptimeSec = $Uptime.TotalSeconds

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "       SYSTEM DIAGNOSTIC REPORT: $PCName        " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Generated on: $(Get-Date)" -ForegroundColor Gray

# --- SECTION 1: IDENTITY & UPTIME ---
Write-Host "`n[1] SYSTEM IDENTITY & UPTIME" -ForegroundColor Yellow
$BIOS = Get-CimInstance Win32_BIOS
$Sys  = Get-CimInstance Win32_ComputerSystem
Write-Host "Manufacturer : $($Sys.Manufacturer)"
Write-Host "Model        : $($Sys.Model)"
Write-Host "Serial Num   : $($BIOS.SerialNumber)"
Write-Host "Windows Ver  : $($OS.Caption) ($($OS.Version))"

# Uptime highlight: Red if over 7 days (Common cause of L1 issues)
$UptimeColor = if ($Uptime.Days -gt 7) {"Red"} else {"Green"}
Write-Host "System Uptime: $($Uptime.Days) Days, $($Uptime.Hours) Hours" -ForegroundColor $UptimeColor

# --- SECTION 2: CPU & PROCESS STRESS ---
Write-Host "`n[2] CPU PERFORMANCE" -ForegroundColor Yellow
$CPU = Get-CimInstance Win32_Processor
$CPUUsage = (Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 1).CounterSamples.CookedValue
$UsageColor = if ($CPUUsage -gt 80) {"Red"} else {"Green"}

Write-Host "Processor    : $($CPU.Name.Trim())"
Write-Host "Current Load : $([math]::Round($CPUUsage, 2))%" -ForegroundColor $UsageColor

Write-Host "`n--- TOP 5 CPU CONSUMERS ---" -ForegroundColor Gray
Get-Process | Where-Object {$_.CPU -gt 1} | Sort-Object CPU -Descending | Select-Object -First 5 Name, 
    @{Name="CPU_Work(s)"; Expression={[math]::Round($_.CPU, 1)}},
    @{Name="Mem(MB)"; Expression={[math]::Round($_.WorkingSet / 1MB, 2)}} | Format-Table -AutoSize

# --- SECTION 3: RAM & UPGRADE POTENTIAL ---
Write-Host "`n[3] MEMORY (RAM) ANALYSIS" -ForegroundColor Yellow
$MemArray = Get-CimInstance Win32_PhysicalMemoryArray
$Sticks   = Get-CimInstance Win32_PhysicalMemory
$AvailableGB = [math]::round($OS.FreePhysicalMemory/1MB, 2)

Write-Host "Total Slots  : $($MemArray.MemoryDevices)"
Write-Host "Used Slots   : $($Sticks.Count)"
Write-Host "Max Capacity : $([math]::Round($MemArray.MaxCapacity / 1MB, 0)) GB"
Write-Host "Available    : $AvailableGB GB" -ForegroundColor (if ($AvailableGB -lt 1) {"Red"} else {"Green"})

Write-Host "`n--- PHYSICAL STICK DETAILS ---" -ForegroundColor Gray
$Sticks | Select-Object BankLabel, @{Name="Size(GB)"; Expression={$_.Capacity / 1GB}}, 
    @{Name="Speed(MHz)"; Expression={$_.ConfiguredClockSpeed}},
    @{Name="Type"; Expression={
        switch($_.SMBIOSMemoryType) {
            20 {"DDR"} 21 {"DDR2"} 24 {"DDR3"} 26 {"DDR4"} 34 {"DDR5"} 
            29 {"LPDDR4"} 30 {"LPDDR4x"} 35 {"LPDDR5"} default {"Other"}
        }
    }} | Format-Table -AutoSize

# --- SECTION 4: STORAGE & BATTERY ---
Write-Host "`n[4] STORAGE & BATTERY HEALTH" -ForegroundColor Yellow
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, HealthStatus, @{Name="Size(GB)"; Expression={$_.Size / 1GB}} | Format-Table -AutoSize

# Battery Health (Laptop Only)
try {
    $Full = Get-CimInstance -Namespace root/WMI -ClassName BatteryFullChargedCapacity -ErrorAction Stop
    $Design = Get-CimInstance -Namespace root/WMI -ClassName BatteryStaticData -ErrorAction Stop
    $Health = [math]::Round(($Full.FullChargedCapacity / $Design.DesignCapacity) * 100, 1)
    $BColor = if ($Health -lt 70) {"Red"} else {"Green"}
    Write-Host "Battery Health: $Health%" -ForegroundColor $BColor
} catch {
    Write-Host "Battery Health: No Battery Detected (Desktop)" -ForegroundColor Gray
}

# --- SECTION 5: SECURITY & UPDATES ---
Write-Host "`n[5] SECURITY & SYSTEM HEALTH" -ForegroundColor Yellow
$Defender = Get-MpComputerStatus
$SecColor = if ($Defender.AntivirusEnabled) {"Green"} else {"Red"}
Write-Host "Antivirus Enabled  : $($Defender.AntivirusEnabled)" -ForegroundColor $SecColor

$LastUpdate = Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 1
Write-Host "Last Windows Patch : $($LastUpdate.InstalledOn) ($($LastUpdate.HotFixID))"

Write-Host "`n===============================================" -ForegroundColor Cyan
Write-Host "           DIAGNOSTIC COMPLETE                 " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Pause
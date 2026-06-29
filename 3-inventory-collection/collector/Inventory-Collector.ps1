# ==========================================================================
# Script Name:  Inventory-Collector.ps1
# Description: Automated Hardware Inventory & Asset Collection Tool & command to self delete.
# Why: Standard Operating Procedure (SOP) requires accurate, up-to-date 
#      inventory. This script eliminates manual entry errors and ensures 
#      consistent data collection for the Centralized Asset Database.
# ==========================================================================


# --- 1. CONFIGURATION (EDIT LISTS HERE) ---

# State/Region List
# To remove a state, simply delete the line or add a '#' at the start.
$StateList = @(
    "Johor"
    "Kedah"
    "Kelantan"
    "Melaka"
    "Negeri Sembilan"
    "Pahang"
    "Penang"
    "Perak"
    "Perlis"
    "Sabah"
    "Sarawak"
    "Selangor"
    "Terengganu"
    "W.P. Kuala Lumpur"
    "W.P. Labuan"
    "W.P. Putrajaya"
)

# Branch Office List
# Tip: Group these logically (e.g., by Region) to make them easier to find.
$BranchList = @(
    "HQ - Main Office"
    "Branch-01"
    "Branch-02"
    "Branch-03"
    "Branch-04"
    "Branch-05"
    "Branch-06"
    "Branch-07"
    "Branch-08"
    "Branch-09"
    "Branch-10"
    "Branch-11"
    "Branch-12"
    "Branch-13"
    "Branch-14"
)

# --- 2. HELPER FUNCTIONS (Technician UI) ---
function Get-UserSelection {
    param (
        [string]$Title,
        [array]$Options
    )
    while ($true) {
        Clear-Host
        Write-Host "===============================================" -ForegroundColor Cyan
        Write-Host "       SELECT $Title FOR INVENTORY REPORT      " -ForegroundColor Cyan
        Write-Host "===============================================" -ForegroundColor Cyan
        for ($i = 0; $i -lt $Options.Count; $i++) {
            Write-Host (" [{0,2}] {1}" -f ($i + 1), $Options[$i])
        }
        
        $choice = Read-Host "`nSelect Option (1-$($Options.Count))"
        if ($choice -as [int] -and [int]$choice -ge 1 -and [int]$choice -le $Options.Count) {
            return $Options[[int]$choice - 1]
        }
        Write-Host "Invalid selection." -ForegroundColor Red ; Start-Sleep -Seconds 1
    }
}

# --- 3. DATA COLLECTION ---
$BranchState = Get-UserSelection -Title "STATE" -Options $StateList
$BranchName  = Get-UserSelection -Title "BRANCH" -Options $BranchList

Clear-Host
Write-Host "Inventory: Querying WMI/CIM System Instances..." -ForegroundColor Cyan

# Gathering System Objects
$CS   = Get-CimInstance Win32_ComputerSystem
$OS   = Get-CimInstance Win32_OperatingSystem
$BIOS = Get-CimInstance Win32_BIOS
$CPU  = Get-CimInstance Win32_Processor | Select-Object -First 1

# Advanced RAM Logic: Converting SMBIOS codes to human-readable generations
$MemorySticks = Get-CimInstance Win32_PhysicalMemory
$RAM_Details = ($MemorySticks | ForEach-Object {
    $Size = [math]::Round($_.Capacity / 1GB, 0)
    $Gen = switch($_.SMBIOSMemoryType) {
        20 {"DDR"} 21 {"DDR2"} 24 {"DDR3"} 26 {"DDR4"} 34 {"DDR5"}
        29 {"LPDDR4"} 30 {"LPDDR4x"} 35 {"LPDDR5"} default {"Other"}
    }
    "$($Size)GB $($Gen)@$($_.ConfiguredClockSpeed)MHz"
}) -join " | " 

# Advanced Disk Logic: Identifying Boot Drive and Media Type (SSD/HDD)
try {
    $Disk = Get-PhysicalDisk | Where-Object { $_.IsBoot -eq $true } | Select-Object -First 1
    if (!$Disk) { $Disk = Get-PhysicalDisk | Select-Object -First 1 }
    $DiskInfo = "$($Disk.FriendlyName) ($($Disk.MediaType))"
} catch { $DiskInfo = "Unknown" }

# Network Logic: Capturing all Physical MAC Addresses
$MAC_Report = (Get-NetAdapter -Physical | ForEach-Object {
    "$($_.InterfaceAlias) ($($_.Status)): $($_.PermanentAddress)"
}) -join " | "

# User Audit: Identifying local accounts (Excluding System Built-ins)
$LocalUsers = (Get-CimInstance Win32_UserAccount -Filter "LocalAccount=True" | 
    Where-Object { $_.Name -notmatch "Guest|DefaultAccount|WDAGUtilityAccount" } | 
    ForEach-Object { if ($_.Name -eq "IT") { "IT (ADMIN)" } else { $_.Name } }) -join " | "

# --- 4. REPORT GENERATION ---
$Report = [PSCustomObject]@{
    Timestamp     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    State         = $BranchState
    Branch        = $BranchName
    PC_Name       = $env:COMPUTERNAME
    Manufacturer  = $CS.Manufacturer
    Model         = $CS.Model
    Serial_Number = $BIOS.SerialNumber
    OS_Version    = $OS.Caption
    Install_Date  = $OS.InstallDate.ToString("yyyy-MM-dd")
    CPU           = $CPU.Name.Trim()
    RAM_Total     = "$([math]::Round(($CS.TotalPhysicalMemory / 1GB), 0)) GB"
    RAM_Specs     = $RAM_Details
    Storage       = $DiskInfo
    Storage_SN    = $Disk.SerialNumber.Trim()
    Disk_Health   = $Disk.HealthStatus
    MAC_Addresses = $MAC_Report
    Local_Users   = $LocalUsers
}



# 5. Export
$FileName = "Report_$($BranchName)_$($PCName)_$($Date).csv"
$Report | Export-Csv -Path (Join-Path $ExportPath $FileName) -NoTypeInformation

Write-Host "===============================================" -ForegroundColor Green
Write-Host "File Exported to IT_Reports Folder in Desktop" -ForegroundColor Green
Write-Host "Please send this file to the IT Department." -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Pause

# --- 3-SECOND SELF-DESTRUCT SEQUENCE ---
Write-Host "`nCleaning up temporary files... This window will close automatically." -ForegroundColor Gray

# Get the path of the current running EXE
$ExePath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName

# The command: 
# 1. Timeout /t 3: Waits exactly 3 seconds
# 2. del: Deletes the EXE
# 3. exit: Closes the background CMD
Start-Process cmd.exe -ArgumentList "/c timeout /t 03 /nobreak && del /f /q `"$ExePath`"" -WindowStyle Hidden
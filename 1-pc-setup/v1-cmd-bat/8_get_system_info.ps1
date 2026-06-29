# ===========================================
# Script Name: get_system_info.ps1
# Description: Collects Hardware/OS specs and saves to a text file.
# ===========================================

$computerName = $env:COMPUTERNAME
$outputFile = "$PSScriptRoot\$computerName_System_Info.txt"

# Create/Clear the file and add a header
"SYSTEM INVENTORY REPORT" | Out-File -FilePath $outputFile
"Generated on: $(Get-Date)" | Out-File -FilePath $outputFile -Append
"===========================================" | Out-File -FilePath $outputFile -Append

Write-Host "Collecting information for $computerName..." -ForegroundColor Cyan

# 1. System & BIOS (Manufacturer, Model, Serial)
"--- Computer & BIOS Information ---" | Out-File -FilePath $outputFile -Append
$Bios = Get-CimInstance Win32_Bios
$Sys  = Get-CimInstance Win32_ComputerSystem
$Bios | Select-Object @{Name="Manufacturer";Expression={$Sys.Manufacturer}}, 
                      @{Name="Model";Expression={$Sys.Model}}, 
                      SerialNumber, SMBIOSBIOSVersion | Format-List | Out-File -FilePath $outputFile -Append

# 2. Operating System
"--- Operating System ---" | Out-File -FilePath $outputFile -Append
Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, OSArchitecture, InstallDate | Format-List | Out-File -FilePath $outputFile -Append

# 3. Processor
"--- Processor ---" | Out-File -FilePath $outputFile -Append
Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed | Format-List | Out-File -FilePath $outputFile -Append

# 4. Memory (RAM)
"--- RAM Capacity ---" | Out-File -FilePath $outputFile -Append
$TotalRAM = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB
"Total Physical Memory: $([Math]::Round($TotalRAM, 2)) GB" | Out-File -FilePath $outputFile -Append
"" | Out-File -FilePath $outputFile -Append

# 5. Disk Information
"--- Storage Information ---" | Out-File -FilePath $outputFile -Append
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, @{Name="Size(GB)";Expression={[Math]::Round($_.Size/1GB,2)}} | Format-List | Out-File -FilePath $outputFile -Append

Write-Host "Success! Inventory saved to: $outputFile" -ForegroundColor Green
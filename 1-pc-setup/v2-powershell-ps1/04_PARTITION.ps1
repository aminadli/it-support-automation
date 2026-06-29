# ==========================================================================
# Script Name: 04_PARTITION.ps1
# Description: Shrinks C: and creates a 270GB D: "DATA" partition.
# Why: Standard Operating Procedure (SOP) requires a dedicated data partition
#      to protect user data and ensure consistent image configurations.
# ==========================================================================

# --- CONFIGURATION ---
$SourceDrive = "C"
$NewDriveLetter = "D"
$NewDriveSize = 270GB    # Target size for the new D: drive
$Label = "DATA"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "          DISK PARTITION MANAGER               " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# --- 1. CONFLICT CHECK (USB BLOCKING) ---
if (Get-PSDrive -Name $NewDriveLetter -ErrorAction SilentlyContinue) {
    Write-Host ""
    Write-Host " [!] ERROR: Drive ${NewDriveLetter}: is currently in use!" -ForegroundColor Red
    Write-Host " Your USB drive is likely blocking this letter." -ForegroundColor Yellow
    Write-Host ""
    Write-Host " ACTION REQUIRED: Please run 'MOVE USB TO Z' first." -ForegroundColor White -BackgroundColor Red
    Write-Host ""
    return 
}

# --- 2. CALCULATE SPACE ---
$C_Partition = Get-Partition -DriveLetter $SourceDrive
$CurrentSize = $C_Partition.Size

# Pro-Check: Ensure C: actually has enough space to shrink
if ($CurrentSize -le ($NewDriveSize + 50GB)) {
    Write-Host " [!] ERROR: Not enough space on ${SourceDrive}: to create a ${NewDriveSize/1GB}GB partition." -ForegroundColor Red
    return
}

$TargetCSize = $CurrentSize - $NewDriveSize

# --- 3. EXECUTION ---

# Step A: Shrink C:
Write-Host "[1/3] Shrinking ${SourceDrive}: by ${NewDriveSize/1GB}GB..." -ForegroundColor Cyan
try {
    # We use -ErrorAction Stop to jump to the 'catch' block if it fails
    Resize-Partition -DriveLetter $SourceDrive -Size $TargetCSize -ErrorAction Stop
} catch {
    Write-Host " [!] ERROR: Windows could not shrink the partition." -ForegroundColor Red
    Write-Host " Note: Unmovable files (Pagefile/ShadowCopies) may be blocking the shrink." -ForegroundColor Yellow
    return
}

# Step B: Create the New Partition
Write-Host "[2/3] Creating new partition as ${NewDriveLetter}:..." -ForegroundColor Cyan
$DiskNum = $C_Partition.DiskNumber
$NewPart = New-Partition -DiskNumber $DiskNum -DriveLetter $NewDriveLetter -UseMaximumSize

# Step C: Format and Label
Write-Host "[3/3] Formatting ${NewDriveLetter}: as $Label (NTFS)..." -ForegroundColor Cyan
Format-Volume -DriveLetter $NewPart.DriveLetter -FileSystem NTFS -NewFileSystemLabel $Label -Confirm:$false

Write-Host "`n===============================================" -ForegroundColor Cyan
Write-Host " SUCCESS! Drive ${NewDriveLetter}: (270GB) is ready." -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Cyan
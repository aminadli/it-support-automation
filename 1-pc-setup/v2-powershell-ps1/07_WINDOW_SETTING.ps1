# ==============================================================================
# Script Name: 07_WINDOW_SETTING.ps1
# Description: Applies Corporate Baseline System Optimizations.
# Why: Standardizes power behavior, security policies, and network identity 
#      to ensure consistent performance and management across the fleet.
# Includes: Hibernation, Password Policies, MAC Randomization, and Power Plans.
# ==============================================================================

# --- 1. ADMIN PRIVILEGE CHECK ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrative privileges required. Please run via the Master Launcher."
    Pause
    exit
}

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "       SYSTEM OPTIMIZATION & POLICIES          " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# --- 2. BASELINE POLICIES (AUTOMATIC) ---
Write-Host "[+] Applying Corporate Baseline Policies..." -ForegroundColor Yellow

# A. Disable Hibernation
# Why: Prevents 'Fast Startup' kernel persistence which causes uptime bugs.
Write-Host "  - Disabling Hibernation..."
powercfg /h off

# B. Disable Wi-Fi MAC Randomization
# Why: Prevents 'ghost' devices in DHCP/Inventory and allows for consistent
#      MAC-based network filtering.
Write-Host "  - Disabling Wi-Fi MAC Randomization..."
$WlanPolicyPath = "HKLM:\Software\Policies\Microsoft\Windows\WlanSvc\GroupPolicy"
$WlanPrefPath   = "HKLM:\SOFTWARE\Microsoft\WlanSvc\Interfaces"

if (-not (Test-Path $WlanPolicyPath)) { New-Item -Path $WlanPolicyPath -Force | Out-Null }
Set-ItemProperty -Path $WlanPolicyPath -Name "RandomMacAddress" -Value 0 -Type DWord

# Apply to all physical Wi-Fi interfaces
$Interfaces = Get-ChildItem -Path $WlanPrefPath -ErrorAction SilentlyContinue
foreach ($Int in $Interfaces) {
    Set-ItemProperty -Path $Int.PSPath -Name "RandomMacAddress" -Value 0 -Type DWord -ErrorAction SilentlyContinue
}
Restart-Service WlanSvc -Force -ErrorAction SilentlyContinue

# C. Local Security Authority (LSA) / Password Policy
Write-Host "  - Setting Local Password Policy (Unlimited Age)..."
net accounts /maxpwage:unlimited
net accounts /lockoutthreshold:0

# Ensure all enabled users inherit 'Never Expire' flag
Get-LocalUser | Where-Object { $_.Enabled -eq $true } | Set-LocalUser -PasswordNeverExpires $true

Write-Host "[OK] Baseline policies applied." -ForegroundColor Green
Write-Host "-----------------------------------------------"

# --- 3. POWER & SLEEP CONFIGURATION (INTERACTIVE) ---
Write-Host "[?] Select Power Plan Profile:" -ForegroundColor White
Write-Host " 1. Standard (5 Minute Timeout)"
Write-Host " 2. High Availability (Always On / Never Sleep)"
Write-Host " 3. Skip Power Configuration"

$choice = Read-Host "Select Option (1-3)"

if ($choice -eq '1' -or $choice -eq '2') {
    $min = if ($choice -eq '1') { 5 } else { 0 }
    $sec = $min * 60

    # Apply to both AC (Plugged In) and DC (Battery)
    powercfg /setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE $sec
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE $sec
    powercfg /setacvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE $sec
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE $sec
    
    # Refresh active scheme
    powercfg /setactive SCHEME_CURRENT
    
    $StatusText = if($min -eq 0){"NEVER"} else {"$min Minutes"}
    Write-Host "[OK] Power timeout set to: $StatusText" -ForegroundColor Green
} else {
    Write-Host "[!] Skipping power configuration." -ForegroundColor Gray
}

# --- FINAL STATUS ---
Write-Host "`n===============================================" -ForegroundColor Cyan
Write-Host "    ALL SYSTEM CONFIGURATIONS COMPLETED        " -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Cyan
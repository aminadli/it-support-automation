# L1 IT Support: PC Provisioning & Automation Toolkit

## 🚀 The Mission
Setting up a new corporate PC manually is a time-consuming process (typically 4-8 hours) prone to human error and inconsistency. This repository contains a suite of automation tools I developed to standardize the deployment lifecycle, reducing setup time to **under 45 minutes** while ensuring 100% configuration accuracy.

## 📈 Performance Impact
*   **Manual Setup:** ~4-8 Hours
*   **Batch v1 Automation:** ~2 Hours


---

## 🛠 Batch v1 Automation Toolkit Overview

### A. System Preparation & Identity
*   **`1 wmic.bat`**: Restores WMIC functionality on Windows 11 to ensure compatibility with legacy management tools.
*   **`2 rename pc.bat`**: A standardized tool to establish computer identity without navigating deep into the Windows UI.

### B. Access Control & Security
*   **`3 local user account.bat`**: Automates the provisioning of Local Admin and Staff accounts. 
*   **`4 remove user account.bat`**: Post-setup sanitization script to remove insecure default accounts (e.g., "user", "Owner") shipped by OEMs/shop.

### C. System Optimization & Hardening
*   **`5 change window setting .bat`**: A comprehensive script that applies 15+ settings in one click, including:
    *   Disabling Fast Startup (Stability)
    *   Configuring Account Lockout/Expiry Policies
    *   Enabling Remote Desktop (RDP) for support teams
    *   Legacy SMB support for office hardware compatibility

### D. Software & Peripheral Deployment
*   **`6 OFFICE SOFTWARE.bat`**: A "Smart" installer using `Winget`. Includes a custom **PowerShell Fallback Mechanism** that downloads official MSIs directly from vendor CDNs if the package manager fails.
*   **`7 scan folder setup.bat`**: Automates the "Triple Crown" of SMB sharing: Folder creation, NTFS Inheritance, and Network Share permissions for office scanners.

### E. Asset Management
*   **`8 get systeminfo.bat` / `8_get_system_info.ps1`**: A portable inventory tool that generates a detailed hardware/BIOS report. Used to populate internal Asset Management databases with 100% accurate serial numbers and specs.

---

## 🧠 Evolution: Batch to PowerShell
This repository documents my transition from **Legacy Batch (CMD)** to **Modern PowerShell**. 
*   **Batch:** Focused on speed and ease of use in WinPE/Environment setups.
*   **PowerShell:** Focused on object-oriented data, error handling, and secure credential management.

## ⚠️ Disclaimer & Usage
These scripts are intended for use by IT Professionals. 
1.  **Sanitization:** All company-specific IPs and passwords have been replaced with placeholders.
2.  **Permissions:** Scripts must be executed as **Administrator**.
3.  **Testing:** Always test in a virtual environment (VM) before deploying to production hardware.

---
**Author:** aminadli
**Role:** L1 Technical Support  
**Focus:** Automation, Scripting, and Systems Efficiency

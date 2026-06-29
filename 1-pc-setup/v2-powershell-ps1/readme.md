# 🚀 Enterprise PC Provisioning & Automation Toolkit

## 📊 Overview & Impact
This toolkit was engineered to transform the manual workstation setup process into a standardized, automated workflow. By moving from manual checklists to this scripted framework, I reduced deployment time from **~8 hours per machine to under 45 minutes**, ensuring 100% compliance with corporate Security and SOP standards.

---

## 🖥️ Central Orchestration: The Master Control Menu
**Files:** `000-Master-Setup.bat` & `000-Master-Setup.ps1`
*   **The Concept:** A centralized "Master Menu" serving as a single point of control for the entire provisioning process.
*   **Key Features:**
    *   **Self-Elevation:** Automatically requests Admin privileges and handles PowerShell execution policy bypass.
    *   **Modular Execution:** Uses switch-case logic to call external sub-scripts, allowing for easy updates without breaking the main menu.
    *   **Power User Shortcuts:** Rapid Restart/Shutdown commands that skip pending updates to save time during high-volume setups.

---

## 🛠️ Phase 1: System Stabilization & Disk Management

### 🛑 Windows Update Suppressor (The "Nuke" Script)
**Script:** `01_PAUSE_UPDATE.ps1`
*   **The Problem:** Background updates consume bandwidth/CPU and lock files required for software installation during setup.
*   **The Solution:** Forcefully terminates update worker processes, clears the `SoftwareDistribution` cache, and enforces a 7-day pause via Registry.
*   **Key Features:** Renames the download folder for a clean state and kills `MoUsoCoreWorker` immediately.

### 🔀 USB Drive Relocator (SOP Enforcer)
**Script:** `03_USB_PATH.ps1`
*   **The Problem:** USB drives often "squat" on the `D:` letter, which is reserved by SOP for local data partitions.
*   **The Solution:** A "hand-off" script that moves the running USB drive to `Z:`.
*   **Key Features:** Generates a temporary background Batch file to release the drive lock and self-cleans after execution.

### 💽 Automated Disk Partitioning
**Script:** `04_PARTITION.ps1`
*   **The Problem:** Manual partitioning is slow and leads to inconsistent drive sizes across the fleet.
*   **The Solution:** Calculates disk math to shrink the OS partition and creates a formatted 270GB "DATA" volume.
*   **Key Features:** Includes pre-flight capacity checks and conflict detection for the `D:` drive letter.

---

## 🔐 Phase 2: Identity, Access & Security

### 🏷️ Hostname Standardization Utility
**Script:** `06_RENAME_PC.ps1`
*   **The Problem:** Inconsistent names make tracking difficult in Management Consoles (Sophos, Spiceworks, Firewalls).
*   **The Solution:** Enforces naming conventions with feedback on NetBIOS (15-character) compatibility.

### 👥 Automated User Provisioning (with Login Fix)
**Script:** `05_CREATE_USER.ps1`
*   **The Problem:** Manual account creation is tedious, and Windows often hides local users from the login screen.
*   **The Solution:** Provisions Admin/Staff accounts and applies a **Winlogon Registry Patch** for 100% UI visibility.

### 🧹 Post-Setup Account Sanitizer
**Script:** `11_REMOVE_USER.ps1`
*   **The Problem:** OEM hardware ships with insecure default accounts (e.g., 'user', 'owner') that create security "technical debt."
*   **The Solution:** Discovers and classifies local accounts, allowing technicians to safely purge non-essential profiles.

---

## ⚙️ Phase 3: System Optimization & Hardening

### 🛡️ Corporate Endpoint Hardening
**Script:** `07_WINDOW_SETTING.ps1`
*   **The Problem:** Default "Home" settings (MAC randomization, hibernation) interfere with enterprise management.
*   **The Solution:** Applies a corporate baseline for security and network identity.
*   **Key Features:** Disables MAC randomization for asset tracking and provides **dynamic power profiles** (Stationary vs. Mobile user roles).

### 🚀 Endpoint Debloat & Bloatware Remover
**Script:** `08_UNINSTALL_APP.ps1`
*   **The Problem:** OEM "Bloatware" consumes resources and increases the attack surface.
*   **The Solution:** Targets both UWP/Store apps and legacy Win32/MSI programs using Regex-based ordering for complex stacks (e.g., HP Wolf Security).

### 🕒 NTP Time & Timezone Synchronizer
**Script:** `09_SYNC_TIME.ps1`
*   **The Problem:** Clock drift causes SSL/TLS handshake failures and VPN connectivity errors.
*   **The Solution:** Enforces GMT+8 and forces an immediate resync with Microsoft’s NTP servers.

---

## 📦 Phase 4: Deployment, Enrollment & Auditing

### 🏗️ Enterprise Software Deployment Framework
**Script:** `14_SOFTWARE_INSTALL.ps1`
*   **The Problem:** Varied department stacks require custom configs (registry fixes, profile imports) that are easily missed manually.
*   **The Solution:** An **Object-Oriented Framework** using "Blueprints" to handle silent installs and custom logic hooks (e.g., AnyDesk passwords, VPN profiles).

### 🌐 Google Workspace Chrome Enrollment
**Script:** `15_IMPORT_TOKEN.ps1`
*   **The Problem:** Forgetting to enroll browsers leads to unmanaged devices in the Google Admin Console.
*   **The Solution:** Injects Cloud Management Enrollment Tokens into the Registry with an **Order of Operations Guardrail** (checks hostname first).

### 📊 Automated Asset Discovery & Inventory Auditor
**Script:** `16_SPEC.ps1`
*   **The Problem:** Manual asset tracking is the #1 source of "Bad Data" in IT departments.
*   **The Solution:** Queries the CIM/BIOS layer for 100% accurate specs, including RAM generation (DDR3/4/5), Disk health, and MAC addresses.

---

## 🔄 Closing the Loop
### ✅ Resume Updates
**Script:** `99_RESUME_UPDATE.ps1`
*   **The Logic:** Restores Windows Update services and removes registry flags. This ensures the device is fully patched and compliant before being handed over to the end-user.

---

### 💡 Career Evolution: From Batch to PowerShell
This repository documents my transition from **Legacy Procedural Scripting (Batch)** to **Advanced Data-Driven Automation (PowerShell)**. By decoupling "Data" from "Logic," I have created a scalable framework that can be maintained by any member of the IT team.

**Author:** aminadli  
**Role:** L1 Technical Support (Focused on Automation & Systems Efficiency)

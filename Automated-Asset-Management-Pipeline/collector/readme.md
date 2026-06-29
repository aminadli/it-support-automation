# 🛠️ The Endpoint Collector

This component is responsible for local data harvesting. It is designed to be distributed to end-users as a standalone, non-intrusive executable.

## 📄 Files
*   **`Inventory-Collector.ps1`**: The core logic that queries hardware specs (CPU, RAM, Disk, MAC) and exports a local CSV.
*   **`Compile-Launcher.bat`**: A build script that utilizes the `ps2exe` module to compile the PowerShell script into a portable Windows Executable (.exe).

## 🚀 Key Features
*   **Hardware Intelligence:** Uses CIM/WMI instances to identify RAM generations (DDR3/4/5) and Disk media types (SSD/HDD).
*   **Self-Cleanup:** Upon completion, the script triggers a background CMD process that waits 5 seconds and then deletes the executable from the user's system.
*   **Zero-Dependency:** Compiled as a Win32 binary to ensure it runs on workstations without requiring the user to interact with the PowerShell console.

## 🛠️ How to Build
1. Open PowerShell and install the compiler: `Install-Module -Name ps2exe -Force`
2. Run `Compile-Launcher.bat`.
3. Distribute the resulting `IT-Audit-Tool.exe` to staff.

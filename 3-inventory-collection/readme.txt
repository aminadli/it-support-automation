# 🚀 Automated Asset Management Pipeline

## 📌 Project Overview
This project is a serverless, end-to-end hardware inventory solution designed to solve the problem of outdated asset records in a remote-work environment. It replaces expensive RMM suites with a custom pipeline using **PowerShell**, **Google Apps Script**, and **Cloud Integration**.

### 🏗️ Architecture: The 3-Stage Pipeline

#### 1. The Collector (PowerShell & PS2EXE)
A compiled standalone executable distributed to end-users. 
* **Deep Audit:** Queries CIM/WMI for hardware specs, RAM generations, and Disk health.
* **Zero-Footprint:** Features a 3-second self-destruct sequence to ensure no IT tools or temporary files remain on user workstations.

#### 2. The Transport (Google Workspace)
* **Ingestion:** Users upload the generated CSV via a secure Google Form.
* **Storage:** Files are isolated in a specific Google Drive landing folder.

#### 3. The Aggregator (JavaScript / Google Apps Script)
* **Automated ETL:** A backend script that parses incoming CSVs and appends data to a Master Asset Database.

---

## 📈 Business Impact
* **Cost:** $0 (Utilizes existing Google Workspace & Native Windows tools).
* **Speed:** Reduced total inventory collection time from weeks to minutes of manual oversight.
* **Accuracy:** Eliminated human error by pulling data directly from BIOS/CIM.

## 🛠️ Setup Instructions
1. **Collector:** Modify the `$StateList` in `Inventory-Collector.ps1` and compile using the provided Batch script.
2. **Cloud:** Create a Google Sheet, open the Script Editor, and paste `Merge-Reports.gs`.
3. **Connect:** Update the `folderId` in the script to match your Google Drive landing folder.

---
**Disclaimer:** This tool was developed to solve real-world inventory gaps. Always ensure compliance with company security policies before distributing executables.

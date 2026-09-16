# 🛠️ IT Support Automation & Systems Engineering Toolkit

A professional portfolio of sanitized PowerShell and Batch scripts developed to automate the lifecycle of enterprise endpoints. This toolkit transforms manual L1 support tasks into reliable, scalable, and data-driven processes.

## 📊 Business Impact & ROI
*   **Provisioning Efficiency:** Reduced new PC setup time from **8 hours to ~45 minutes**.
*   **Data Integrity:** Eliminated human error in hardware auditing with 100% accurate BIOS-level data collection.
*   **Scalability:** Engineered a serverless inventory pipeline capable of auditing 100+ remote endpoints with zero infrastructure costs.
*   **Consistency:** Standardized local security policies and software baselines across multiple office branches.

---

## 📁 Repository Structure

### 1. [Provisioning & Deployment](./1-pc-setup)
*Automated "Out of the Box" (OOBE) setup scripts designed for rapid deployment.*
*   **000-Master-Setup**: A unified CLI menu interface allowing technicians to execute specific tasks from a single launcher.
*   **System Hardening**: Registry-based optimizations, power policy enforcement, and automated bloatware removal.
*   **Modular Software Installer**: A data-driven framework for silent application deployment with custom failover logic and post-install hooks.
*   **User Management**: Automated provisioning of Admin/Staff accounts with custom login screen visibility patches.

### 2. [Diagnostics & Remediation](./troubleshooting)
*Reactive support tools used to identify and resolve common performance and connectivity issues.*
*   **System Health Auditor**: A "Pre-flight" diagnostic tool that audits CPU stress, RAM health, and battery wear levels with color-coded alerts for easy triage.
*   **Network Repair Utility**: Flushes the TCP/IP stack and optimizes WiFi driver registry keys to resolve intermittent connectivity and roaming issues.
*   **Performance Optimizer**: Deep-cleans system caches and optimizes the Windows Component Store (DISM) to restore system responsiveness.

### 3. [Automated Asset Management Pipeline](./Automated-Asset-Management-Pipeline)
*An end-to-end serverless data pipeline for hardware auditing.*
*   **The Collector**: A compiled PowerShell executable (.EXE) with a 5-second self-destruct sequence for secure, portable inventory collection on remote devices.
*   **The Aggregator**: A JavaScript-based Google Apps Script backend that automatically merges fragmented CSV uploads into a centralized Master Asset Database.

---

## 🧠 The Evolution: Batch ➜ PowerShell ➜ Systems Design
This repository documents my transition from **Legacy Procedural Scripting** (Batch) to **Advanced Data-Driven Automation** (PowerShell).

*   **Batch Phase:** Focused on simple, reliable execution in CMD environments for basic file manipulation.
*   **PowerShell Phase:** Transitioned to object-oriented frameworks, utilizing `CimInstances`, `ScriptBlocks`, and `PSCustomObjects` for robust error handling and modularity.
*   **Systems Design:** Integrated local scripting with Cloud services (Google Workspace) to build cross-platform data pipelines, demonstrating a shift toward **Infrastructure as Code (IaC)** logic.

---

## ⚙️ Usage & Security
1.  **Sanitization:** All company-specific passwords, IP addresses, and Secret Keys have been replaced with `CHANGE_ME` or `REDACTED` placeholders.
2.  **Elevation:** All scripts require **Administrative Privileges** to modify registry keys, system services, and local hardware configurations.
3.  **Portability:** Scripts utilize `$PSScriptRoot` and relative pathing to ensure the toolkit remains portable for use on technician USB drives or network shares.

---
**Author:** Amin Adli 
**Role:** L1/L2 Technical Support | Automation Enthusiast  

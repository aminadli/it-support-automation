### Phase 1: Automated System Diagnostic
**Script:** `DIAGNOSTIC_REPORT.ps1`  
**The Problem:** Troubleshooting often begins without accurate data. Low system resources or extreme uptime (>7 days without a restart) are frequent root causes that are often overlooked.  
**The Solution:** A comprehensive "Pre-Flight" diagnostic tool that audits CPU, RAM, Disk health, and Battery cycles.  
**Key Features:**
*   **Health Thresholds:** Color-coded alerts for critical issues like high uptime or low available memory.
*   **Upgrade Readiness:** Detects physical RAM slots and motherboard capacity to determine hardware eligibility for upgrades.
*   **Hardware Logic:** Differentiates between SSD/HDD media types and calculates battery wear levels.

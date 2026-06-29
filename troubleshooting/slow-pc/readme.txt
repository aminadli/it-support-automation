
## 🛠️ Performance & Troubleshooting Workflow
When a user reports a "Slow PC," I follow a three-stage automated and manual remediation process to identify the root cause.

### Phase 1: Automated System Diagnostic
**Script:** `DIAGNOSTIC_REPORT.ps1`  
**The Problem:** Troubleshooting often begins without accurate data. Low system resources or extreme uptime (>7 days without a restart) are frequent root causes that are often overlooked.  
**The Solution:** A comprehensive "Pre-Flight" diagnostic tool that audits CPU, RAM, Disk health, and Battery cycles.  
**Key Features:**
*   **Health Thresholds:** Color-coded alerts for critical issues like high uptime or low available memory.
*   **Upgrade Readiness:** Detects physical RAM slots and motherboard capacity to determine hardware eligibility for upgrades.
*   **Security Audit:** Verifies Antivirus status and patch compliance.
*   **Hardware Logic:** Differentiates between SSD/HDD media types and calculates battery wear levels.

### Phase 2: Automated Performance Remediation
**Script:** `SLOW_PC_FIX.ps1`  
**The Problem:** Over time, Windows endpoints accumulate "Digital Trash" (cache, temp files, redundant update components) that causes high disk latency and sluggish UI responsiveness.  
**The Solution:** A deep-cleaning utility that purges system caches and optimizes the Windows Component Store.  
**Key Features:**
*   **Component Store Optimization:** Uses `DISM` to prune superseded Windows Update files, reclaiming significant disk space.
*   **Multi-Layer Purge:** Targets User, System, and Prefetch temporary directories.
*   **UI Refresh:** Clears Explorer thumbnail/icon caches to resolve sluggish file browsing.

### Phase 3: Advanced Hardware Stress Testing & Escalation
If software remediation (Phase 2) does not resolve the issue despite healthy-looking specifications (Phase 1), I proceed to deep hardware analysis:

1.  **Stress Testing:** Utilize **OCCT** for CPU/RAM stability and **CrystalDiskMark** to verify Read/Write speeds against manufacturer baselines.
2.  **S.M.A.R.T. Analysis:** Use **CrystalDiskInfo** to check for disk errors. 
    *   *Note:* Even if S.M.A.R.T. status is "Good," I investigate for **Degraded Controllers** if IO latency remains high.
3.  **OS Re-imaging:** If hardware tests pass, perform data migration and a clean **OS Re-image** to eliminate deep-seated registry or profile corruption.
4.  **Hardware Replacement:** If re-imaging fails or IO bottlenecks persist, I escalate for **SSD/Hardware Replacement**.

---

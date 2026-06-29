### Phase 2: Automated Performance Remediation
**Script:** `SLOW_PC_FIX.ps1`  
**The Problem:** Over time, Windows endpoints accumulate "Digital Trash" (cache, temp files, redundant update components) that causes high disk latency and sluggish UI responsiveness.  
**The Solution:** A deep-cleaning utility that purges system caches and optimizes the Windows Component Store.  
**Key Features:**
*   **Component Store Optimization:** Uses `DISM` to prune superseded Windows Update files, reclaiming significant disk space.
*   **Multi-Layer Purge:** Targets User, System, and Prefetch temporary directories.
*   **UI Refresh:** Clears Explorer thumbnail/icon caches to resolve sluggish file browsing.

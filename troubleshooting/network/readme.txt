> ### 📶 Network & WiFi Repair Utility
> **Script:** `NETWORK_RESET.ps1`
> * **The Problem:** Staff frequently report "Limited Connectivity" or WiFi dropping out when moving between office zones. Standard Windows troubleshooting often fails to address driver-level power saving and roaming behaviors.
> * **The Solution:** A comprehensive remediation script that flushes the TCP/IP stack and applies driver optimizations directly to the Windows Registry.
> * **Key Features:**
>   * **Stack Sanitization:** Resets Winsock, TCP/IP, and flushes DNS cache in one operation.
>   * **Power Management Fix:** Modifies `PnPCapabilities` to prevent Windows from turning off the WiFi adapter to save power—the #1 cause of "No Internet after Sleep."
>   * **Roaming Optimization:** Sets `RoamingAggressiveness` to a stable baseline to prevent unnecessary Access Point hopping in high-density office environments.
>   * **Safe Execution:** Automatically filters out virtual/VPN adapters to ensure only physical hardware is modified.

> **📍 Escalation Path:**
> If this script is executed and connectivity issues persist, it indicates the problem likely exists at the **Infrastructure Level** (e.g., Access Point failure, DHCP scope exhaustion, or ISP outage). 
> 
> *   **Next Step:** Escalate the ticket to the **Network Engineering Team**. 
> *   **Reasoning:** Local client-side remediation has been exhausted; back-end infrastructure access is required for further investigation.

---

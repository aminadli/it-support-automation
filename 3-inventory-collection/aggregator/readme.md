# ☁️ The Cloud Aggregator

This component serves as the backend of the pipeline, transforming fragmented user uploads into a centralized Master Asset Database.

## 📄 Files
*   **`Merge-Reports.gs`**: Google Apps Script (JavaScript) designed to run within a Google Sheet.

## ⚙️ Logic Flow
1.  **Ingestion:** The script targets a specific Google Drive folder ID where user-uploaded CSVs are stored.
2.  **ETL Process (Extract, Transform, Load):** 
    *   **Extract:** Opens every CSV file found in the landing zone.
    *   **Transform:** Parses the raw CSV string into a data array.
    *   **Load:** Appends the data row to the active Google Sheet.
3.  **Archiving:** Once a file is successfully merged, the script renames it with a `PROCESSED_` prefix to prevent duplicate entries during the next run.

## 🛠️ Setup Instructions
1. Create a new **Google Sheet**.
2. Go to `Extensions` > `Apps Script`.
3. Paste the contents of `Merge-Reports.gs`.
4. Replace `YOUR_GOOGLE_DRIVE_FOLDER_ID` with the ID of the folder where your Google Form saves uploads.
5. Create a "Time-driven" trigger if you wish for the merge to happen automatically every hour.

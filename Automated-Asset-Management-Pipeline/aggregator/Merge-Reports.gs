
function mergeBranchReports() {
  var folderId = "YOUR_GOOGLE_DRIVE_FOLDER_ID"; 
  var folder = DriveApp.getFolderById(folderId);
  var files = folder.getFilesByType(MimeType.CSV);
  
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getActiveSheet();
  
  while (files.hasNext()) {
    var file = files.next();
    var content = file.getBlob().getDataAsString();
    var csvData = Utilities.parseCsv(content);
    
    // Assuming the CSV has 1 row of headers and 1 row of data
    // Data starts at index 1
    if (csvData.length > 1) {
      var rowData = csvData[1]; 
      
      // OPTIONAL: Check if Computer Name already exists to avoid duplicates
      // sheet.appendRow(rowData);
      
      sheet.appendRow(rowData);
      
      // 2. IMPORTANT: Move the file to an 'Archive' folder so it doesn't merge again next time
      // For now, we will just rename it so you know it's "Done"
      file.setName("PROCESSED_" + file.getName());
    }
  }
}

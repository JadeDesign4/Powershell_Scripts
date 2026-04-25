# Simple Windows Notification
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Backup Started for Documents Folder')"

# 1. Identify the flash drive by its label
$DriveLabel = "MY_FLASH_DRIVE" 
$USB = Get-Volume -FileSystemLabel $DriveLabel | Select-Object -ExpandProperty DriveLetter

# 2. Check if the drive is actually plugged in
if ($null -eq $USB) {
    Write-Host "Error: Flash drive '$DriveLabel' not found!" -ForegroundColor Red
    exit
}

# 3. Define Source and Destination
$Source = "$HOME\Documents"
$Destination = "$($USB):\Documents"

# 4. Run the backup using Robocopy
# /MIR  = Mirror (adds new files, updates changed ones, deletes what you deleted)
# /MT   = Multithreaded (makes it much faster)
# /R:3  = Retry 3 times if a file is busy
# /W:5  = Wait 5 seconds between retries
Write-Host "Backing up Documents to $Destination..." -ForegroundColor Cyan
robocopy $Source $Destination /MIR /MT /R:3 /W:5

Write-Host "Backup Complete!" -ForegroundColor Green
# Simple Windows Notification
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Backup Completed for Documents Folder')"

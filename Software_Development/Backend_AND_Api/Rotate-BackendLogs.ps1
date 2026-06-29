<#
.SYNOPSIS
    Archives oversized active log definitions into compressed zip format and resets stream handles.
.DESCRIPTION
    NAME:        Rotate-BackendLogs.ps1
    TARGET:      Backend Developers, DevOps Engineers, & System Administrators
    PROBLEM:     Deleting logs destroys debug history, but letting them grow 
                 indefinitely fills disk sectors and crashes the backend.
    USAGE:       .\Rotate-BackendLogs.ps1 -LogPath ".\logs"
#>

param (
    [string]$LogPath = ".\logs"
)

$Timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$SizeThresholdBytes = 10MB

Write-Host "🔄 Initiating Automated Backend Log Rotator & Archiver..." -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Gray

if (-not (Test-Path $LogPath)) {
    Write-Host "💡 Creating directory '$LogPath' and generating sample log matrix..." -ForegroundColor Yellow
    New-Item -Path $LogPath -ItemType Directory | Out-Null
    
    # Generate mock log files for testing execution flow
    $Stream = [System.IO.File]::Create((Join-Path $LogPath "api-server.log"))
    $Stream.SetLength(11MB)
    $Stream.Close()
    
    $Stream = [System.IO.File]::Create((Join-Path $LogPath "database.log"))
    $Stream.SetLength(2MB)
    $Stream.Close()
}

Write-Host "🔍 Scanning '$LogPath' for logs exceeding $($SizeThresholdBytes / 1MB)MB..." -ForegroundColor Yellow
Write-Host "---------------------------------------------------------------" -ForegroundColor Gray

$RotatedCount = 0
$LogFiles = Get-ChildItem -Path $LogPath -Filter *.log

foreach ($File in $LogFiles) {
    if ($File.Length -ge $SizeThresholdBytes) {
        $DisplaySize = [Math]::Round($File.Length / 1MB, 2)
        Write-Host "📦 Target Identified: $($File.Name) ($DisplaySize MB)" -ForegroundColor White
        
        $ArchiveName = "$($File.FullName).$Timestamp.zip"
        
        # 1. Archive the historical records natively into a standard ZIP package
        Compress-Archive -Path $File.FullName -DestinationPath $ArchiveName -Force
        
        # 2. Clear the active operational log file without removing or breaking locked open threads
        Clear-Content -Path $File.FullName -ErrorAction SilentlyContinue
        
        Write-Host "   ✅ Compressed to: $(Split-Path $ArchiveName -Leaf)" -ForegroundColor Green
        Write-Host "   ✅ Active log reset to 0 bytes cleanly." -ForegroundColor Green
        $RotatedCount++
    } else {
        $DisplaySize = [Math]::Round($File.Length / 1MB, 2)
        Write-Host "   ├── $($File.Name) ($DisplaySize MB) is within safety margins." -ForegroundColor DarkGray
    }
}

Write-Host "---------------------------------------------------------------" -ForegroundColor Gray
Write-Host "🎉 Clean execution complete! Rotated $RotatedCount log stream(s)." -ForegroundColor Green
Write-Host "===============================================================" -ForegroundColor Gray
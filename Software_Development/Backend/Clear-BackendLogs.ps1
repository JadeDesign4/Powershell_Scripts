<#
.SYNOPSIS
    Safely clears/truncates application log files to 0 bytes.
.DESCRIPTION
    NAME:        Clear-BackendLogs.ps1
    TARGET:      Backend Developers, Sysadmins, & Power Users
    PROBLEM:     Backend application logs balloon over time, consuming local disk 
                 space and making debugging fresh errors incredibly tedious.
    USAGE:       .\Clear-BackendLogs.ps1 -TargetDir "C:\path\to\logs"
.PARAMETER TargetDir
    The path to the folder containing log files. Defaults to the current directory.
#>

param (
    [string]$TargetDir = "."
)

# Resolve path to absolute format
$ResolvedPath = Resolve-Path $TargetDir -ErrorAction SilentlyContinue

if (-not $ResolvedPath) {
    Write-Host "❌ Error: Directory '$TargetDir' does not exist." -ForegroundColor Red
    Exit 1
}

Write-Host "🔍 Scanning for log files in: $($ResolvedPath.Path)" -ForegroundColor Cyan
Write-Host "--------------------------------------------------"

# Get all .log files in the target folder
$LogFiles = Get-ChildItem -Path $ResolvedPath.Path -Filter "*.log" -File -Recurse -ErrorAction SilentlyContinue

if (-not $LogFiles) {
    Write-Host "🎉 No .log files found. Your workspace is perfectly clean!" -ForegroundColor Green
    Exit 0
}

$TotalSavedBytes = 0

foreach ($File in $LogFiles) {
    $TotalSavedBytes += $File.Length
    
    # Safely truncate the file to 0 bytes using Clear-Content (keeps file handle & permissions)
    Clear-Content -Path $File.FullName -ErrorAction SilentlyContinue
    
    # Human readable size conversion
    if ($File.Length -ge 1MB) {
        $ReadableSize = "$([Math]::Round($File.Length / 1MB, 2)) MB"
    } elseif ($File.Length -ge 1KB) {
        $ReadableSize = "$([Math]::Round($File.Length / 1KB, 2)) KB"
    } else {
        $ReadableSize = "$($File.Length) Bytes"
    }

    Write-Host "🧹 Cleared: $($File.Name) ($ReadableSize cleared)" -ForegroundColor Magenta
}

Write-Host "--------------------------------------------------"
$TotalSavedMB = [Math]::Round($TotalSavedBytes / 1MB, 2)

if ($TotalSavedMB -gt 0) {
    Write-Host "✅ Success! Safely reclaimed approx. $TotalSavedMB MB of disk space." -ForegroundColor Green
} else {
    Write-Host "✅ Success! All log files have been reset to 0 bytes." -ForegroundColor Green
}

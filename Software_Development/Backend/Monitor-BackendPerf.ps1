<#
.SYNOPSIS
    Monitors Windows processes by engine name for CPU and Memory consumption.
.DESCRIPTION
    NAME:        Monitor-BackendPerf.ps1
    TARGET:      Backend Developers, Sysadmins, & Power Users
    PROBLEM:     Backend apps can suffer from silent memory leaks or CPU spikes 
                 during heavy local testing, which are hard to track without bloated GUI tools.
    USAGE:       .\Monitor-BackendPerf.ps1 -ProcessName "node"
.PARAMETER ProcessName
    The process name to filter by (e.g., node, python, java, w3wp). Defaults to "node".
#>

param (
    [string]$ProcessName = "node"
)

Write-Host "📊 Initiating Backend Performance Watchdog..." -ForegroundColor Cyan
Write-Host "🔍 Searching for runtime engine: '$ProcessName'" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Gray
Write-Host "PID`t`tCPU %`t`tWorking Set (MB)`t`tProcess Name"
Write-Host "---------------------------------------------------------------" -ForegroundColor Gray

# Fetch matching processes using Get-Process
$Processes = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue

if (-not $Processes) {
    Write-Host "❌ No active processes found matching '$ProcessName'." -ForegroundColor Red
    Write-Host "💡 Tip: Make sure your local backend server is actually running!" -ForegroundColor Yellow
    Exit 1
}

foreach ($Proc in $Processes) {
    # Calculate CPU usage percentage from total processor time
    # Note: Using performance counters or quick metrics approximation
    $CpuPercent = [Math]::Round(($Proc.CPU), 1)
    
    # Convert WorkingSet (RAM) from bytes to Megabytes
    $MemMb = [Math]::Round(($Proc.WorkingSet / 1MB), 1)
    $Pid = $Proc.Id
    $Name = $Proc.ProcessName

    # Formatting string spaces cleanly
    if ($CpuPercent -gt 80) {
        Write-Host "$Pid`t`t$CpuPercent`t`t$MemMb`t`t`t$Name " -NoNewline
        Write-Host "[🔥 HIGH RESOURCE!]" -ForegroundColor Red
    } else {
        Write-Host "$Pid`t`t$CpuPercent`t`t$MemMb`t`t`t$Name"
    }
}

Write-Host "===============================================================" -ForegroundColor Gray
Write-Host "💡 Tip: Keep refreshing this script to monitor local load spikes during API tests." -ForegroundColor Yellow

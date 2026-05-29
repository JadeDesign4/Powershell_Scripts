# Get physical memory details using CIM/WMI
$ComputerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
$OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem

# 1. Total Physical RAM
$TotalBytes = $ComputerSystem.TotalPhysicalMemory
$TotalGB = [math]::Round($TotalBytes / 1GB, 2)

# 2. Available Physical RAM
$AvailableKB = $OperatingSystem.FreePhysicalMemory
$AvailableGB = [math]::Round($AvailableKB / 1MB, 2)

# 3. Used Physical RAM
$UsedGB = [math]::Round($TotalGB - $AvailableGB, 2)

# 4. Swap / Paging File Memory (Virtual Memory Allocation)
$TotalVirtualKB = $OperatingSystem.TotalVirtualMemorySize
$FreeVirtualKB = $OperatingSystem.FreeVirtualMemory
$UsedVirtualKB = $TotalVirtualKB - $FreeVirtualKB

# Swap Available is calculated by subtracting free physical memory from free virtual memory
$SwapAvailableKB = $FreeVirtualKB - $AvailableKB
$SwapTotalKB = $TotalVirtualKB - ($TotalBytes / 1KB)
$SwapUsedKB = $SwapTotalKB - $SwapAvailableKB

# Convert Swap metrics to GB safely (prevent negative bounds if paging file is disabled or system managed)
$SwapTotalGB = [math]::Round([math]::Max(0, $SwapTotalKB) / 1MB, 2)
$SwapUsedGB = [math]::Round([math]::Max(0, $SwapUsedKB) / 1MB, 2)

# Clear screen for crisp readability
Clear-Host

# Write output format cleanly to the terminal shell
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "       WINDOWS SYSTEM MEMORY STATUS       " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Total Physical RAM  : $TotalGB GB" -ForegroundColor White
Write-Host " Used Physical RAM   : $UsedGB GB" -ForegroundColor Yellow
Write-Host " Available RAM       : $AvailableGB GB" -ForegroundColor Green
Write-Host "-----------------------------------------" -ForegroundColor Gray
Write-Host " Total Swap/Paging   : $SwapTotalGB GB" -ForegroundColor White
Write-Host " Used Swap/Paging    : $SwapUsedGB GB" -ForegroundColor DarkYellow
Write-Host "=========================================" -ForegroundColor Cyan

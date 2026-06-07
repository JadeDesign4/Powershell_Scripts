# Clear the screen for a clean output
Clear-Host

# Color configurations
$Green  = "Green"
$Yellow = "Yellow"
$Red    = "Red"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "         WINDOWS SYSTEM HEALTH REPORT             " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

Start-Sleep 1

# 1. BATTERY CHECK
Write-Host "`n[+] Checking Battery Status..." -ForegroundColor White
$Batteries = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue

if ($Batteries) {
    foreach ($Bat in $Batteries) {
        $Capacity = $Bat.EstimatedChargeRemaining
        # Status code 2 means "Unknown" or "Discharging", status 3 means "Fully Charged", 6 means "Charging"
        $StatusDescription = switch ($Bat.BatteryStatus) {
            1 { "Discharging" }
            2 { "Unknown (On Battery)" }
            3 { "Fully Charged" }
            4 { "Low" }
            5 { "Critical" }
            6 { "Charging" }
            default { "Unknown" }
        }

        Write-Host "Current Charge: $Capacity%"
        Write-Host "Status: $StatusDescription"

        if ($Capacity -le 15 -and $StatusDescription -ne "Charging") {
            Write-Host "Result: CRITICAL (Battery Low & Not Charging)" -ForegroundColor $Red
        } elseif ($Capacity -le 30 -and $StatusDescription -ne "Charging") {
            Write-Host "Result: WARNING (Battery getting low)" -ForegroundColor $Yellow
        } else {
            Write-Host "Result: GOOD" -ForegroundColor $Green
        }
    }
} else {
    Write-Host "No battery found (Desktop PC or Virtual Machine)." -ForegroundColor Gray
}

Start-Sleep 1

# 2. STORAGE CHECK (C: Drive)
Write-Host "`n[+] Checking Storage / C: Drive..." -ForegroundColor White
$CDrive = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"

if ($CDrive) {
    $TotalSpace = $CDrive.Size
    $FreeSpace = $CDrive.FreeSpace
    $UsedSpace = $TotalSpace - $FreeSpace
    $StorageUsagePct = [math]::Round(($UsedSpace / $TotalSpace) * 100)

    Write-Host "C: Drive Usage: $StorageUsagePct%"

    if ($StorageUsagePct -ge 90) {
        Write-Host "Result: CRITICAL (Storage almost full!)" -ForegroundColor $Red
    } elseif ($StorageUsagePct -ge 75) {
        Write-Host "Result: WARNING (Storage filling up)" -ForegroundColor $Yellow
    } else {
        Write-Host "Result: GOOD" -ForegroundColor $Green
    }
}

Start-Sleep 1

# 3. RAM/MEMORY CHECK
Write-Host "`n[+] Checking RAM Utilization..." -ForegroundColor White
$OSInfo = Get-CimInstance -ClassName Win32_OperatingSystem
$TotalRAM = $OSInfo.TotalVisibleMemorySize
$FreeRAM = $OSInfo.FreePhysicalMemory
$UsedRAM = $TotalRAM - $FreeRAM
$RamUsagePct = [math]::Round(($UsedRAM / $TotalRAM) * 100)

Write-Host "RAM Usage: $RamUsagePct%"

if ($RamUsagePct -ge 90) {
    Write-Host "Result: CRITICAL (System is choking on RAM)" -ForegroundColor $Red
} elseif ($RamUsagePct -ge 75) {
    Write-Host "Result: WARNING (High memory usage)" -ForegroundColor $Yellow
} else {
    Write-Host "Result: GOOD" -ForegroundColor $Green
}

Start-Sleep 2

# 4. CPU LOAD CHECK
Write-Host "`n[+] Checking CPU Load..." -ForegroundColor White
# Takes a quick 1-second sample of current CPU utilization
$CpuLoad = (Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 1).CounterSamples.CookedValue
$CpuLoadPct = [math]::Round($CpuLoad)

Write-Host "CPU Load: $CpuLoadPct%"

if ($CpuLoadPct -ge 90) {
    Write-Host "Result: CRITICAL (CPU is overloaded)" -ForegroundColor $Red
} elseif ($CpuLoadPct -ge 75) {
    Write-Host "Result: WARNING (CPU load is heavy)" -ForegroundColor $Yellow
} else {
    Write-Host "Result: GOOD" -ForegroundColor $Green
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "         HEALTH REPORT COMPLETE :)             " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

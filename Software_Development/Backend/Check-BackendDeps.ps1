<#
.SYNOPSIS
    Probes network ports to verify backend dependency availability.
.DESCRIPTION
    NAME:        Check-BackendDeps.ps1
    TARGET:      Backend Developers, Sysadmins, & Power Users
    PROBLEM:     Backend apps crash on startup with cryptic connection errors when 
                 dependencies (databases, caches, third-party APIs) are offline.
    USAGE:       .\Check-BackendDeps.ps1
#>

# Define your dependencies here using an array of custom objects
$Dependencies = @(
    [PSCustomObject]@{ Name = "Local-PostgreSQL"; Host = "127.0.0.1"; Port = 5432 }
    [PSCustomObject]@{ Name = "Local-Redis";      Host = "127.0.0.1"; Port = 6379 }
    [PSCustomObject]@{ Name = "Local-MongoDB";    Host = "127.0.0.1"; Port = 27017 }
    [PSCustomObject]@{ Name = "GitHub-API";       Host = "api.github.com"; Port = 443 }
)

# Timeout in milliseconds
$TimeoutMs = 2000

Write-Host "🔍 Starting Backend Dependency Health Check..." -ForegroundColor Cyan
Write-Host "=================================================="
Write-Host "  STATUS  |  SERVICE NAME       |  ADDRESS:PORT"
Write-Host "--------------------------------------------------"

foreach ($Dep in $Dependencies) {
    $TcpClient = New-Object System.Net.Sockets.TcpClient
    
    # Attempt network connection asynchronously to enforce the timeout
    $Connect = $TcpClient.BeginConnect($Dep.Host, $Dep.Port, $null, $null)
    $Wait = $Connect.AsyncWaitHandle.WaitOne($TimeoutMs, $true)
    
    if ($Wait -and $TcpClient.Connected) {
        # Successfully connected
        $Status = "[ UP ]"
        Write-Host "  $Status  " -NoNewline -ForegroundColor Green
        Write-Host "|  $($Dep.Name.PadRight(18)) |  $($Dep.Host):$($Dep.Port)"
        $TcpClient.EndConnect($Connect)
    } else {
        # Connection failed or timed out
        $Status = "[DOWN]"
        Write-Host "  $Status  " -NoNewline -ForegroundColor Red
        Write-Host "|  $($Dep.Name.PadRight(18)) |  $($Dep.Host):$($Dep.Port)"
    }
    
    # Close socket handle cleanly
    $TcpClient.Close()
    $TcpClient.Dispose()
}

Write-Host "=================================================="
Write-Host "💡 Tip: If a dependency is [DOWN], ensure its service/docker container is running." -ForegroundColor Yellow
<#
.SYNOPSIS
    Pings target backend routes to index HTTP response codes and connection latency.
.DESCRIPTION
    NAME:        Test-ApiEndpoints.ps1
    TARGET:      Backend Developers, API Engineers, & QA Testers
    PROBLEM:     Manually testing multiple backend routes using Postman or singular 
                 curl commands slows down rapid development and integration loops.
    USAGE:       .\Test-ApiEndpoints.ps1
#>

# Define your backend routes to test (Modify this array to fit your local/dev setup)
$Endpoints = @(
    "https://httpbin.org/status/200",
    "https://httpbin.org/status/404",
    "https://httpbin.org/delay/1"
)

Write-Host "🚀 Initiating Local API Health & Response Validator..." -ForegroundColor Cyan
Write-Host "=======================================================================" -ForegroundColor Gray
Write-Host ("{0,-40} | {1,-12} | {2,-10}" -f "ENDPOINT URL", "HTTP STATUS", "LATENCY")
Write-Host "-----------------------------------------------------------------------" -ForegroundColor Gray

foreach ($Url in $Endpoints) {
    # Truncate long URLs gracefully for dashboard alignment
    $DisplayUrl = $Url
    if ($Url.Length -gt 38) { $DisplayUrl = $Url.Substring(0, 35) + "..." }

    # Setup a fresh stop-watch to measure round-trip execution lag precisely
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        # Execute basic lightweight web request header verification
        $Response = Invoke-WebRequest -Uri $Url -Method Head -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        $Stopwatch.Stop()
        
        $Status = $Response.StatusCode
        Write-Host ("{0,-40} | " -f $DisplayUrl) -NoNewline
        Write-Host ("{0,-12}" -f "$Status OK") -ForegroundColor Green -NoNewline
        Write-Host " | $($Stopwatch.ElapsedMilliseconds) ms"
    }
    catch {
        $Stopwatch.Stop()
        # Extract response code even if it's a caught exception (like 404 or 500 errors)
        $Status = $_.Exception.Response.StatusCode
        if (-not $Status) { $Status = "FAIL" }
        
        Write-Host ("{0,-40} | " -f $DisplayUrl) -NoNewline
        Write-Host ("{0,-12}" -f "$Status ERR") -ForegroundColor Red -NoNewline
        Write-Host " | $($Stopwatch.ElapsedMilliseconds) ms"
    }
}

Write-Host "=======================================================================" -ForegroundColor Gray
Write-Host "🎉 API endpoint screening complete!" -ForegroundColor Green

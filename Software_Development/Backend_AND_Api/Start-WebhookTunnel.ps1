<#
.SYNOPSIS
    Exposes a specified local backend server port to a public endpoint using an ngrok tunnel.
.DESCRIPTION
    NAME:        Start-WebhookTunnel.ps1
    TARGET:      Backend Developers, API Engineers, & Integration Testers
    PROBLEM:     External APIs (Stripe, GitHub) cannot route payloads directly to 
                 localhost:3000, requiring tedious manual proxy setups.
    USAGE:       .\Start-WebhookTunnel.ps1 -Port 3000
#>

param (
    [int]$Port = 3000
)

Write-Host "🌐 Initiating Backend Webhook Tunnel Proxy Automator..." -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Gray

# Verify that ngrok is installed and available in the current PATH environmental context
$NgrokCheck = Get-Command ngrok -ErrorAction SilentlyContinue
if (-not $NgrokCheck) {
    Write-Host "❌ Error: 'ngrok' CLI utility was not found in the current system paths." -ForegroundColor Red
    Write-Host "💡 Instruction: Please install ngrok (https://ngrok.com) or configure your environmental paths." -ForegroundColor Yellow
    Exit 1
}

Write-Host "🚀 Launching secure proxy tunnel pointing to localhost:$Port..." -ForegroundColor Yellow
Write-Host "---------------------------------------------------------------" -ForegroundColor Gray

# Run ngrok as a background job task to keep terminal streams non-blocking
$NgrokJob = Start-Job -ScriptBlock { param($p) & ngrok http $p } -ArgumentList $Port

# Allow the background agent process a brief window to establish network sockets
Start-Sleep -Seconds 3

# Query ngrok's local management API natively to fetch structural connection mappings
try {
    $TunnelData = Invoke-RestMethod -Uri "http://127.0.0.1:4040/api/tunnels" -ErrorAction Stop
    $PublicUrl = $TunnelData.tunnels[0].public_url
}
catch {
    $PublicUrl = $null
}

if (-not $PublicUrl) {
    Write-Host "❌ Error: Failed to extract a public routing URL from the agent infrastructure." -ForegroundColor Red
    Write-Host "💡 Tip: Make sure your ngrok authentication token is configured ('ngrok config add-authtoken <token>')." -ForegroundColor Yellow
    Stop-Job $NgrokJob
    Remove-Job $NgrokJob
    Exit 1
}

Write-Host "🎉 TUNNEL ESTABLISHED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "🔗 Public Entrypoint: " -NoNewline
Write-Host $PublicUrl -ForegroundColor Cyan
Write-Host "👉 Target Endpoint:   http://localhost:$Port"
Write-Host "---------------------------------------------------------------" -ForegroundColor Gray
Write-Host "🛑 Press [CTRL+C] or use Stop-Job to tear down the tunnel and close proxy lines safely." -ForegroundColor Yellow
Write-Host "===============================================================" -ForegroundColor Gray

# Track execution state, processing loop interruptions smoothly
try {
    while ($true) { Start-Sleep -Seconds 1 }
}
finally {
    Write-Host "`n🛑 Tearing down proxy processes cleanly..." -ForegroundColor Red
    Stop-Job $NgrokJob
    Remove-Job $NgrokJob
}

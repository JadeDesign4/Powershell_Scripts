<#
.SYNOPSIS
    Parses structural commands inside a target Dockerfile to catch vulnerabilities and structural anti-patterns.
.DESCRIPTION
    NAME:        Lint-Dockerfile.ps1
    TARGET:      DevOps Engineers, Cloud Architects, & Security Engineers
    PROBLEM:     Misconfigured container builds leak credentials, increase attack 
                 surfaces, and introduce unpredictable breakages in cloud pipelines.
    USAGE:       .\Lint-Dockerfile.ps1 -DockerfilePath ".\Dockerfile"
#>

param (
    [string]$DockerfilePath = "Dockerfile"
)

$FailedRules = 0

Write-Host "🛡️  Initiating Pre-Flight Container Security & Linting Guard..." -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Gray

if (-not (Test-Path $DockerfilePath)) {
    Write-Host "💡 Target '$DockerfilePath' not found. Creating a sample Dockerfile with common anti-patterns for review..." -ForegroundColor Yellow
    $SampleContent = @"
FROM node:latest
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 3000
CMD ["node", "server.js"]
"@
    Out-File -FilePath $DockerfilePath -InputObject $SampleContent -Encoding ascii
}

Write-Host "🔍 Analyzing build manifest instructions: '$DockerfilePath'" -ForegroundColor Yellow
Write-Host "---------------------------------------------------------------" -ForegroundColor Gray

$Content = Get-Content -Path $DockerfilePath

# --- Rule 1: Check for unstable base image configurations (:latest tag) ---
$LatestPattern = "^FROM\s+\S+:latest\b"
$HasTagPattern = "^FROM\s+\S+:\S+"
$FromLines = $Content | Select-String -Pattern "^FROM\s+"

if (($FromLines -match $LatestPattern) -or (-not ($FromLines -match $HasTagPattern))) {
    Write-Host "⚠️  [STABILITY] Unpinned or ':latest' base image detected." -ForegroundColor Yellow
    Write-Host "   👉 Fix: Pin your base layer to a specific version digest (e.g., node:20-alpine)."
    $FailedRules++
}

# --- Rule 2: Check for missing explicit non-root service execution profile ---
if (-not ($Content | Select-String -Pattern "^USER\s+")) {
    Write-Host "🚨 [SECURITY ] Missing non-root 'USER' designation instruction." -ForegroundColor Red
    Write-Host "   👉 Fix: Add 'USER node' or 'USER 10001' to prevent containers running with root host privileges."
    $FailedRules++
}

# --- Rule 3: Check for suspicious environment variables or credentials ---
if ($Content | Select-String -Pattern "ENV\s+.*(PASSWORD|SECRET|TOKEN|KEY)=") {
    Write-Host "🚨 [SECURITY ] Hardcoded sensitive credential placeholders detected inside ENV blocks." -ForegroundColor Red
    Write-Host "   👉 Fix: Inject operational variables via runtime parameter mapping or secrets managers."
    $FailedRules++
}

# --- Rule 4: Check for missing operational availability polling ---
if (-not ($Content | Select-String -Pattern "^HEALTHCHECK")) {
    Write-Host "⚠️  [TELEMETRY] Missing native container 'HEALTHCHECK' definition." -ForegroundColor Yellow
    Write-Host "   👉 Fix: Configure a HEALTHCHECK instruction to allow orchestrators (K8s/ECS) to track readiness."
    $FailedRules++
}

Write-Host "---------------------------------------------------------------" -ForegroundColor Gray
if ($FailedRules -eq 0) {
    Write-Host "🎉 PASSED! Manifest meets baseline security and structural compliance criteria." -ForegroundColor Green
} else {
    Write-Host "❌ REJECTED! Found $FailedRules container validation variance issues listed above." -ForegroundColor Red
}
Write-Host "===============================================================" -ForegroundColor Gray

if ($FailedRules -eq 0) { exit 0 } else { exit 1 }

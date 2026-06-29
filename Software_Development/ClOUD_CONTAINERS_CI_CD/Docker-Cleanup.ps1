<#
.SYNOPSIS
    Evaluates Docker disk space allocation and safely purges detached or dangling system elements.
.DESCRIPTION
    NAME:        Docker-Cleanup.ps1
    TARGET:      Developers using Docker, DevOps Engineers, & Cloud Architects
    PROBLEM:     Unused container layers, stopped instances, and build caches silently 
                 hoard tens of gigabytes of storage over prolonged dev cycles.
    USAGE:       .\Docker-Cleanup.ps1
#>

Write-Host "🐳 Initiating Smart Docker Hygiene & Space Optimizer..." -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Gray

# Verify if the Docker daemon command utility is accessible in the environmental context
$DockerCheck = Get-Command docker -ErrorAction SilentlyContinue
if (-not $DockerCheck) {
    Write-Host "❌ Error: 'docker' CLI utility was not found on this system." -ForegroundColor Red
    Exit 1
}

& docker info 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error: Cannot connect to the Docker daemon." -ForegroundColor Red
    Write-Host "💡 Instruction: Please ensure Docker Desktop or the Docker daemon service is running." -ForegroundColor Yellow
    Exit 1
}

Write-Host "📊 Step 1: Evaluating current Docker storage footprint..." -ForegroundColor Yellow
Write-Host "---------------------------------------------------------------" -ForegroundColor Gray
& docker system df

Write-Host "---------------------------------------------------------------" -ForegroundColor Gray
Write-Host "🧹 Step 2: Commencing safe, targeted resource extraction..." -ForegroundColor Yellow
Write-Host "---------------------------------------------------------------" -ForegroundColor Gray

# 1. Clear stopped containers
Write-Host "🔹 Removing stopped containers..." -ForegroundColor White
& docker container prune -f

# 2. Clear dangling images (orphaned layers with no tag tags)
Write-Host "🔹 Purging dangling images..." -ForegroundColor White
& docker image prune -f

# 3. Clear unused networks
Write-Host "🔹 Clearing empty custom networks..." -ForegroundColor White
& docker network prune -f

# 4. Clear build cache layers
Write-Host "🔹 Compacting BuildKit developer cache matrices..." -ForegroundColor White
& docker builder prune -f

Write-Host "---------------------------------------------------------------" -ForegroundColor Gray
Write-Host "📊 Step 3: Optimization complete! Post-cleanup status:" -ForegroundColor Yellow
Write-Host "---------------------------------------------------------------" -ForegroundColor Gray
& docker system df

Write-Host "===============================================================" -ForegroundColor Gray
Write-Host "🎉 Docker development storage environment successfully optimized!" -ForegroundColor Green

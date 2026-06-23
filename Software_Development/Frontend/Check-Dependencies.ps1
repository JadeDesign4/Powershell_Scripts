<#
.SYNOPSIS
    Audits package.json dependencies for security issues and outdated framework versions.
.DESCRIPTION
    NAME:        Check-Dependencies.ps1
    TARGET:      Frontend Developers, Project Maintainers, & Security Engineers
    PROBLEM:     Outdated or vulnerable third-party packages silently compromise 
                 frontend application security and performance.
    USAGE:       .\Check-Dependencies.ps1
#>

Write-Host "🛡️  Initiating Frontend Dependency Health & Security Guard..." -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Gray

# Verify package.json exists in the current working directory
if (-not (Test-Path "package.json")) {
    Write-Host "❌ Error: 'package.json' not found in this directory." -ForegroundColor Red
    Write-Host "💡 Tip: Run this script from the root folder of your frontend project." -ForegroundColor Yellow
    Exit 1
}

# Check if npm CLI is available on the machine
$NpmCheck = Get-Command npm -ErrorAction SilentlyContinue
if (-not $NpmCheck) {
    Write-Host "❌ Error: 'npm' command utility is not installed or accessible in the current environment path." -ForegroundColor Red
    Exit 1
}

Write-Host "🔍 Step 1: Checking for outdated packages..." -ForegroundColor Yellow
Write-Host "---------------------------------------------------------------" -ForegroundColor Gray
# Execute npm outdated safely without breaking script execution flow on non-zero exit codes
& npm outdated 2>&1 | Out-Default

Write-Host "---------------------------------------------------------------" -ForegroundColor Gray
Write-Host "🔐 Step 2: Auditing open-source dependencies for vulnerabilities..." -ForegroundColor Yellow
Write-Host "---------------------------------------------------------------" -ForegroundColor Gray
& npm audit 2>&1 | Out-Default

Write-Host "===============================================================" -ForegroundColor Gray
Write-Host "🎉 Dependency health screening complete!" -ForegroundColor Green

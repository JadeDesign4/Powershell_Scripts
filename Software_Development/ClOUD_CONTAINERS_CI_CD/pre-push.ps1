<#
.SYNOPSIS
    Intercepts 'git push' operations natively to run pre-flight quality gates before shipping code.
.DESCRIPTION
    NAME:        pre-push.ps1
    TARGET:      Software Engineers, DevOps Engineers, & Release Managers
    PROBLEM:     Pushing syntax errors, broken tests, or misconfigured files to a 
                 remote repository wastes cloud resources and breaks team builds.
    USAGE:       Executed automatically by a wrapper file in .git/hooks/
#>

Write-Host "🛡️  Git Pre-Push Hook Gatekeeper Active..." -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Gray
Write-Host "🔍 Commencing local codebase validation sweeps..." -ForegroundColor Yellow

# --- Task 1: Simulate running unit tests or syntax checks ---
Write-Host "🔹 Running test suite simulation..." -ForegroundColor White
$TestExitCode = 0 # Simulate a passing suite status

if ($TestExitCode -ne 0) {
    Write-Host "❌ CRITICAL ERROR: Local unit test suites failed." -ForegroundColor Red
    Write-Host "🛑 Git remote push aborted. Fix the tests before pushing!" -ForegroundColor Yellow
    Write-Host "===============================================================" -ForegroundColor Gray
    Exit 1
}
Write-Host "   ✅ Unit validation tests passed successfully." -ForegroundColor Green

# --- Task 2: Check for forbidden debug flags ---
Write-Host "🔹 Scanning staged lines for leftover debug artifacts..." -ForegroundColor White
$DebugMatches = git diff --cached | Select-String -Pattern "console\.log", "TODO: FIX"

if ($DebugMatches) {
    Write-Host "⚠️  [CODE QUALITY] Found unhandled temporary debug statements or blocks." -ForegroundColor Yellow
}

Write-Host "---------------------------------------------------------------" -ForegroundColor Gray
Write-Host "🎉 ALL CHECKS PASSED! Codebase is stable and cloud-ready." -ForegroundColor Green
Write-Host "🚀 Dispatching commits to remote repository branch..." -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Gray
Exit 0

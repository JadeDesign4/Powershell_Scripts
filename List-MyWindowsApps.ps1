Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  1. WINGET INSTALLED APPS (Community Repo)       " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
if (Get-Command winget -ErrorAction SilentlyContinue) {
    # Filters to apps pulled explicitly from the winget source
    winget list --source winget
} else { Write-Host "WinGet is not installed." -ForegroundColor Red }

Write-Host "`n==================================================" -ForegroundColor Yellow
Write-Host "  2. SCOOP INSTALLED APPS                         " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Yellow
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    scoop list
} else { Write-Host "Scoop is not installed." -ForegroundColor Red }

Write-Host "`n==================================================" -ForegroundColor Green
Write-Host "  3. CHOCOLATEY INSTALLED APPS                    " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
if (Get-Command choco -ErrorAction SilentlyContinue) {
    # -lo lists local-only explicitly installed packages
    choco list -lo
} else { Write-Host "Chocolatey is not installed." -ForegroundColor Red }

Write-Host "`n==================================================" -ForegroundColor Magenta
Write-Host "  4. MICROSOFT STORE DOWNLOADS                    " -ForegroundColor Magenta
Write-Host "==================================================" -ForegroundColor Magenta
if (Get-Command winget -ErrorAction SilentlyContinue) {
    # This queries your system but isolates apps originating from the MS Store source
    winget list --source msstore
} else { 
    Write-Host "WinGet missing. Falling back to native AppX query..." -ForegroundColor Yellow
    # Fallback method using Windows' underlying AppX package manager
    Get-AppxPackage | Where-Object { $_.IsFramework -eq $false -and $_.NonRemovable -eq $false } | Select-Object Name, Publisher
}

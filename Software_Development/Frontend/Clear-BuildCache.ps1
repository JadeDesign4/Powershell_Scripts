<#
.SYNOPSIS
    Locates and purges temporary frontend build artifacts and local framework cache folders.
.DESCRIPTION
    NAME:        Clear-BuildCache.ps1
    TARGET:      Frontend Developers, Jamstack/Static Site Engineers, & Build Ops
    PROBLEM:     Stale local compilation caches cause weird visual bugs, build
                 regressions, and consume massive amounts of hidden storage.
    USAGE:       .\Clear-BuildCache.ps1
#>

Write-Host "🧹 Initiating Smart Frontend Build Cache Cleaner..." -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Gray

# Array of standard framework build artifact and cache folder names
$CacheTargets = @(".next", "dist", "build", ".turbo", ".cache", "out", ".astro", ".svelte-kit")
$FoundCount = 0

Write-Host "🔍 Scanning current workspace for stale artifacts..." -ForegroundColor Yellow
Write-Host "---------------------------------------------------------------" -ForegroundColor Gray

foreach ($Target in $CacheTargets) {
    # Recursively find directory items matching the target array values, skipping git internals
    $Directories = Get-ChildItem -Path . -Directory -Recurse -Filter $Target -ErrorAction SilentlyContinue |
                   Where-Object { $_.FullName -notmatch '\\\.git\\' }

    foreach ($Dir in $Directories) {
        if (Test-Path $Dir.FullName) {
            Write-Host "🔥 Purging build cache: " -NoNewline -ForegroundColor Red
            Write-Host "$($Dir.FullName.Replace((Get-Location).Path, '.'))" -ForegroundColor White
            
            # Use force/recurse to drop locked or heavy minified files cleanly
            Remove-Item -Path $Dir.FullName -Recurse -Force -ErrorAction SilentlyContinue
            $FoundCount++
        }
    }
}

Write-Host "---------------------------------------------------------------" -ForegroundColor Gray
if ($FoundCount -eq 0) {
    Write-Host "🎉 Workspace is already completely pristine! No stale caches found." -ForegroundColor Green
} else {
    Write-Host "✨ Clean sweep successful! Purged $FoundCount build/cache location(s)." -ForegroundColor Green
    Write-Host "💡 Next Step: Run 'npm run dev' or 'npm run build' for a completely fresh compilation." -ForegroundColor Yellow
}
Write-Host "===============================================================" -ForegroundColor Gray

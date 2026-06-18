<#
.SYNOPSIS
    Deeply scans for and safely purges 'node_modules' folders after confirmation.
.DESCRIPTION
    NAME:        Purge-NodeModules.ps1
    TARGET:      Frontend Developers, UI/UX Engineers, & Power Users
    PROBLEM:     Frontend projects accumulate hidden 'node_modules' folders that 
                 hoard gigabytes of disk space and slow down system file tracking.
    USAGE:       .\Purge-NodeModules.ps1 -SearchDir "C:\Projects"
.PARAMETER SearchDir
    The directory branch to scan. Defaults to the current directory.
#>

param (
    [string]$SearchDir = "."
)

$ResolvedPath = Resolve-Path $SearchDir -ErrorAction SilentlyContinue

if (-not $ResolvedPath) {
    Write-Host "❌ Error: Directory '$SearchDir' does not exist." -ForegroundColor Red
    Exit 1
}

Write-Host "🔍 Scanning for 'node_modules' in: $($ResolvedPath.Path)" -ForegroundColor Cyan
Write-Host "⏳ This might take a moment depending on your storage speed..." -ForegroundColor Cyan
Write-Host "----------------------------------------------------------------" -ForegroundColor Gray

# Locate all node_modules folders recursively
$ModuleFolders = Get-ChildItem -Path $ResolvedPath.Path -Directory -Recurse -Filter "node_modules" -ErrorAction SilentlyContinue |
                 Where-Object { $_.FullName -notmatch '\\\.' } # Ignore hidden paths

if (-not $ModuleFolders) {
    Write-Host "🎉 Clean sweep! No 'node_modules' folders found in this directory tree." -ForegroundColor Green
    Exit 0
}

# Display target directories
Write-Host "⚠️  Found the following 'node_modules' folders:" -ForegroundColor Yellow
foreach ($Folder in $ModuleFolders) {
    Write-Host "👉 $($Folder.FullName)" -ForegroundColor DarkGray
}
Write-Host "----------------------------------------------------------------" -ForegroundColor Gray

# Prompt user explicitly for verification
$Confirmation = Read-Host "🚨 Are you absolutely sure you want to PURGE these folders? (y/N)"
Write-Host "----------------------------------------------------------------" -ForegroundColor Gray

if ($Confirmation -match "^[Yy]$" -or $Confirmation -match "^[Yy][Ee][Ss]$") {
    Write-Host "🧹 Purge authorized. Deleting folders... please wait." -ForegroundColor Yellow
    
    foreach ($Folder in $ModuleFolders) {
        if (Test-Path $Folder.FullName) {
            # Use Force and Recurse to handle massive nested folder trees efficiently
            Remove-Item -Path $Folder.FullName -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "✅ Removed: $($Folder.FullName)" -ForegroundColor Green
        }
    }
    Write-Host "----------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "✨ Done! All target 'node_modules' folders have been successfully purged." -ForegroundColor Green
} else {
    Write-Host "❌ Operation cancelled. No files were altered." -ForegroundColor Red
}

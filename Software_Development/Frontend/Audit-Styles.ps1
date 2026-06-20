<#
.SYNOPSIS
    Scans frontend markup files to index class utility density and flag style layout complexity.
.DESCRIPTION
    NAME:        Audit-Styles.ps1
    TARGET:      Frontend Developers, UI Engineers, & Tailwind/CSS Enthusiasts
    PROBLEM:     CSS utilities and classes easily become bloated and duplicated over 
                 time, leading to messy components and unoptimized build bundles.
    USAGE:       .\Audit-Styles.ps1 -SrcPath ".\src\components"
.PARAMETER SrcPath
    The source directory to check. Defaults to ".\src".
#>

param (
    [string]$SrcPath = ".\src"
)

Write-Host "🎨 Initiating Frontend Stylesheet & Component Auditor..." -ForegroundColor Cyan
Write-Host "📂 Scanning UI directory: $SrcPath" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Gray

if (-not (Test-Path $SrcPath)) {
    Write-Host "❌ Error: Directory '$SrcPath' does not exist." -ForegroundColor Red
    Write-Host "💡 Tip: Run this from your root folder or pass a valid source path." -ForegroundColor Yellow
    Exit 1
}

Write-Host "📊 Top 10 Most Frequently Used Classes/Utilities:" -ForegroundColor Yellow
Write-Host "---------------------------------------------------------------" -ForegroundColor Gray

# Target extensions
$Extensions = @("*.html", "*.js", "*.jsx", "*.tsx", "*.vue", "*.svelte")
$Files = Get-ChildItem -Path $SrcPath -Include $Extensions -File -Recurse -ErrorAction SilentlyContinue

if (-not $Files) {
    Write-Host "🎉 No frontend component or markup files detected in this folder branch." -ForegroundColor Green
    Exit 0
}

$ClassList = [System.Collections.Generic.List[string]]::new()

foreach ($File in $Files) {
    $Content = Get-Content $File.FullName -Raw -ErrorAction SilentlyContinue
    # Match class="anything" or className="anything"
    $Matches = [regex]::Matches($Content, '(?i)class(?:Name)?="([^"]+)"')
    foreach ($Match in $Matches) {
        $Classes = $Match.Groups[1].Value -split '\s+'
        foreach ($Class in $Classes) {
            if (-not [string]::IsNullOrWhiteSpace($Class)) {
                $ClassList.Add($Class.Trim())
            }
        }
    }
}

# Group and display top 10 frequencies
$ClassList | Group-Object | Sort-Object Count -Descending | Select-Object -First 10 | ForEach-Object {
    Write-Host "$($_.Count)`t`t$($_.Name)"
}

Write-Host "---------------------------------------------------------------" -ForegroundColor Gray
Write-Host "⚠️  Checking for Component File Complexity (Potential Bloat):" -ForegroundColor Yellow

foreach ($File in $Files) {
    $Content = Get-Content $File.FullName -Raw -ErrorAction SilentlyContinue
    $MatchCount = [regex]::Matches($Content, '(?i)class(?:Name)?="([^"]+)"').Count
    
    if ($MatchCount -gt 30) {
        Write-Host "   👉 Warning: " -NoNewline -ForegroundColor Yellow
        Write-Host "$($File.Name) " -NoNewline -ForegroundColor White
        Write-Host "has " -NoNewline
        Write-Host "$MatchCount " -NoNewline -ForegroundColor Red
        Write-Host "styling elements. Consider refactoring into atomic components."
    }
}

Write-Host "===============================================================" -ForegroundColor Gray
Write-Host "🎉 Style audit complete! Use these insights to streamline your design system tokens." -ForegroundColor Green

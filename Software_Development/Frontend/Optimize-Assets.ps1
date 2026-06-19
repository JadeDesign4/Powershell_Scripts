<#
.SYNOPSIS
    Smart cross-platform environment scanner to compress frontend image assets.
.DESCRIPTION
    NAME:        Optimize-Assets.ps1
    TARGET:      Frontend Developers, Web Designers, & Content Creators
    PROBLEM:     Uncompressed assets bloat modern frontend deployments and hurt
                 SEO/Lighthouse performance scores.
    USAGE:       .\Optimize-Assets.ps1 -AssetPath ".\src\assets"
.PARAMETER AssetPath
    The target folder containing web assets. Defaults to ".\assets".
#>

param (
    [string]$AssetPath = ".\assets"
)

Write-Host "🖼️  Initiating Smart Frontend Asset Optimizer..." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Gray

if (-not (Test-Path $AssetPath)) {
    Write-Host "⚠️  Directory '$AssetPath' not found. Instantiating a clean directory..." -ForegroundColor Yellow
    New-Item -Path $AssetPath -ItemType Directory | Out-Null
}

# 1. Environment & Capability Check
Write-Host "🖥️  Scanning system capabilities..." -ForegroundColor DarkGray

$Hasmagick = Get-Command magick -ErrorAction SilentlyContinue
$Hasgdi = [bool]([AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.FullName -match "System.Drawing" })

# Find relevant image files
$Images = Get-ChildItem -Path $AssetPath -File -Include *.jpg, *.jpeg, *.png -Recurse -ErrorAction SilentlyContinue

if (-not $Images) {
    Write-Host "🎉 No uncompressed images (.jpg, .jpeg, .png) found in the asset target directory." -ForegroundColor Green
    Exit 0
}

# 2. Execution Route based on available capabilities
if ($Hasmagick) {
    Write-Host "⚙️  Using system detected 'ImageMagick' binary..." -ForegroundColor Yellow
    Write-Host "--------------------------------------------------" -ForegroundColor Gray
    foreach ($Img in $Images) {
        Write-Host "⚡ Compressing: $($Img.Name)"
        & magick convert "$($Img.FullName)" -resize "1200x1200>" -quality 85 "$($Img.FullName)"
        Write-Host "   ✅ Done!" -ForegroundColor Green
    }
}
elseif ($Hasgdi) {
    Write-Host "⚙️  Using Windows native .NET Graphics Pipeline (GDI+)..." -ForegroundColor Yellow
    Write-Host "--------------------------------------------------" -ForegroundColor Gray
    
    # Load the required .NET layout assembly
    Add-Type -AssemblyName System.Drawing
    
    foreach ($Img in $Images) {
        Write-Host "⚡ Streamlining structural metadata for: $($Img.Name)"
        try {
            $Bmp = New-Object System.Drawing.Bitmap($Img.FullName)
            # Re-saving the file through the assembly stream strips unneeded heavy EXIF camera bloat
            $Bmp.Save($Img.FullName + ".tmp", $Bmp.RawFormat)
            $Bmp.Dispose()
            Remove-Item $Img.FullName
            Rename-Item ($Img.FullName + ".tmp") $Img.Name
            Write-Host "   ✅ Done!" -ForegroundColor Green
        }
        catch {
            Write-Host "   ❌ Failed to process via native framework metadata wrapper." -ForegroundColor Red
        }
    }
}
else {
    Write-Host "❌ Windows graphics compiler engine/assemblies could not be reached." -ForegroundColor Red
    Write-Host "💡 Tip: Install ImageMagick ('winget install ImageMagick.ImageMagick') for automated scaling support." -ForegroundColor Yellow
}

Write-Host "==================================================" -ForegroundColor Gray
Write-Host "🎉 Asset optimization routine completed for '$AssetPath'!" -ForegroundColor Green

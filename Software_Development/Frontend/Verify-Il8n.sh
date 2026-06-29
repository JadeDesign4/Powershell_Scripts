<#
.SYNOPSIS
    Compares object property schemas across local JSON asset configs to flag layout drift.
.DESCRIPTION
    NAME:        Verify-I18n.ps1
    TARGET:      Frontend Developers, Content Managers, & i18n Engineers
    PROBLEM:     Adding feature text keys to a primary config (e.g., en.json) but 
                 forgetting others causes broken UI labels and missing web text.
    USAGE:       .\Verify-I18n.ps1 -LocalePath ".\public\locales"
.PARAMETER LocalePath
    The path to the folder containing your project's configuration files. Defaults to ".\locales".
#>

param (
    [string]$LocalePath = ".\locales"
)

Write-Host "🌐 Initiating Translation & Config Integrity Guard..." -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Gray

if (-not (Test-Path $LocalePath)) {
    Write-Host "⚠️  Directory '$LocalePath' not found. Creating placeholder files..." -ForegroundColor Yellow
    New-Item -Path $LocalePath -ItemType Directory | Out-Null
    '{"title": "Hello", "button": "Submit"}' | Out-File (Join-Path $LocalePath "en.json") -Encoding utf8
    '{"title": "Hola"}' | Out-File (Join-Path $LocalePath "es.json") -Encoding utf8
}

$Files = Get-ChildItem -Path $LocalePath -Filter *.json | Sort-Object Name

if ($Files.Count -lt 2) {
    Write-Host "💡 Found $($Files.Count) JSON file(s). Need at least 2 config files in '$LocalePath' to run validation checks." -ForegroundColor Yellow
    Exit 0
}

$PrimaryFile = $Files[0]
Write-Host "📘 Using primary reference base: $($PrimaryFile.Name)" -ForegroundColor Canvas
Write-Host "---------------------------------------------------------------" -ForegroundColor Gray

# Import reference file keys natively using safe ConvertFrom-Json parser
try {
    $PrimaryJson = Get-Content $PrimaryFile.FullName -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
    $PrimaryKeys = $PrimaryJson.psobject.properties.name
} catch {
    Write-Host "❌ Critical Error: Could not cleanly parse JSON file structural layout for $($PrimaryFile.Name)." -ForegroundColor Red
    Exit 1
}

$DriftFound = $false

for ($i = 1; $i -lt $Files.Count; $i++) {
    $CompareFile = $Files[$i]
    Write-Host "🔍 Auditing: $($CompareFile.Name) against reference..." -ForegroundColor Yellow
    
    try {
        $CompareJson = Get-Content $CompareFile.FullName -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
        $CompareKeys = $CompareJson.psobject.properties.name
        
        # Check if any primary keys are missing in the comparison file list
        $MissingKeys = Compare-Object -ReferenceObject $PrimaryKeys -DifferenceObject $CompareKeys -SideIndicator "<=" -PassThru
        
        if ($MissingKeys) {
            Write-Host "   ❌ MISSING KEYS DETECTED:" -ForegroundColor Red
            foreach ($Key in $MissingKeys) {
                Write-Host "      👉 [ ] $Key" -ForegroundColor DarkGray
            }
            $DriftFound = $true
        } else {
            Write-Host "   ✅ Structure fully aligned!" -ForegroundColor Green
        }
    } catch {
        Write-Host "   ❌ Error parsing configuration structure for this file." -ForegroundColor Red
    }
    Write-Host "---------------------------------------------------------------" -ForegroundColor Gray
}

if ($DriftFound) {
    Write-Host "⚠️  Drift detected. Update your configuration files to match the reference structure." -ForegroundColor Yellow
    Exit 1
} else {
    Write-Host "🎉 Alignment perfect! All layout configuration matrices match exactly." -ForegroundColor Green
}

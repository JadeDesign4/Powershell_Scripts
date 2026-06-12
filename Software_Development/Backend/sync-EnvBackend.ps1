<#
.SYNOPSIS
    Compares .env.example with .env and appends missing keys.
.DESCRIPTION
    Target: Backend Developers / Power Users
#>

$ExampleFile = ".env.example"
$EnvFile = ".env"

# 1. Check if .env.example exists
if (-not (Test-Path $ExampleFile)) {
    Write-Host "❌ Error: $ExampleFile not found in the current directory." -ForegroundColor Red
    Exit 1
}

# 2. If .env doesn't exist at all, create it from the example
if (-not (Test-Path $EnvFile)) {
    Write-Host "⚠️  $EnvFile missing. Creating it from $ExampleFile..." -ForegroundColor Yellow
    Copy-Item $ExampleFile $EnvFile
    Write-Host "✅ Created $EnvFile successfully." -ForegroundColor Green
    Exit 0
}

Write-Host "🔄 Comparing environment files..." -ForegroundColor Cyan
$MissingKeysCount = 0

# Get all keys currently in the .env file
$CurrentEnvKeys = @{}
Get-Content $EnvFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith('#') -and $line.Contains('=')) {
        $key = $line.Split('=')[0].Trim()
        $CurrentEnvKeys[$key] = $true
    }
}

# 3. Read .env.example line by line and find missing keys
Get-Content $ExampleFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith('#') -and $line.Contains('=')) {
        $key = $line.Split('=')[0].Trim()
        
        # If the key isn't in our hashtable, it's missing
        if (-not $CurrentEnvKeys.ContainsKey($key)) {
            Write-Host "➕ Appending missing key: $key" -ForegroundColor Magenta
            Add-Content -Path $EnvFile -Value $_
            $MissingKeysCount++
        }
    }
}

# 4. Final summary
if ($MissingKeysCount -eq 0) {
    Write-Host "🎉 Your $EnvFile is fully up to date with $ExampleFile!" -ForegroundColor Green
} else {
    Write-Host "✅ Successfully added $MissingKeysCount missing variable(s) to $EnvFile." -ForegroundColor Green
}

<#
.SYNOPSIS
    Scans files in the current directory for hardcoded secrets and credentials.
.DESCRIPTION
    NAME:        Scan-Secrets.ps1
    TARGET:      Backend Developers, Sysadmins, & Power Users
    PROBLEM:     Accidentally committing credentials (like AWS keys or DB passwords) 
                 to Git repositories leads to massive security breaches.
    USAGE:       .\Scan-Secrets.ps1
#>

Write-Host "🔒 Initiating Local Secret & Token Scanner..." -ForegroundColor Cyan
Write-Host "=================================================="

# Define regex patterns for strings likely containing secrets
$Patterns = @(
    "(password|passwd|secret|db_password|pwd)\s*=\s*['`"][^'`"]+['`"]"
    "(?i)bearer\s+[a-zA-Z0-9_\-\.]+"
    "-----BEGIN [A-Z]+ PRIVATE KEY-----"
    "AKIA[0-9A-Z]{16}" # Strict AWS Access Key ID match
)

$LeaksFound = 0

# Get all files recursively, excluding git directories, log files, markdown, and this script
$Files = Get-ChildItem -Path . -File -Recurse -ErrorAction SilentlyContinue | 
         Where-Object { $_.FullName -notmatch '\\\.git\\' -and $_.Name -notmatch 'Scan-Secrets\.ps1$' -and $_.Extension -notin '.log','.md' }

foreach ($File in $Files) {
    $LineNum = 0
    # Read file line by line
    Get-Content $File.FullName -ErrorAction SilentlyContinue | ForEach-Object {
        $LineNum++
        $CurrentLine = $_
        
        foreach ($Pattern in $Patterns) {
            if ($CurrentLine -match $Pattern) {
                Write-Host "⚠️  POSSIBLE LEAK DETECTED " -NoNewline -ForegroundColor Red
                Write-Host "in " -NoNewline
                Write-Host "$($File.FullName.Replace((Get-Location).Path, '.')) " -NoNewline -ForegroundColor Yellow
                Write-Host "on line $LineNum"
                Write-Host "   👉 Line: $($CurrentLine.Trim())" -ForegroundColor DarkGray
                Write-Host "--------------------------------------------------"
                $LeaksFound++
                break # Match found for this line, jump to next line
            }
        }
    }
}

# Final Status Dashboard
Write-Host "=================================================="
if ($LeaksFound -eq 0) {
    Write-Host "🎉 Scan clean! No obvious hardcoded secrets or tokens found." -ForegroundColor Green
} else {
    Write-Host "❌ Scan complete. Found $LeaksFound potential secret leak(s)!" -ForegroundColor Red
    Write-Host "💡 Recommendation: Remove these secrets or move them safely into a .env file immediately." -ForegroundColor Yellow
}
# Get Days of the week in 7 days time.

for ( $i = 0; $i -le 6; $i++ ) {
    Write-Host "Today is" -ForegroundColor Yellow (Get-Date).AddDays($i).ToLongDateString()
}
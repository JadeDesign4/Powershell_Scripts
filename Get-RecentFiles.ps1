# List all files Created or Modified in the last 5 days.

Get-ChildItem -File | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-5) -or $_.CreationTime -gt (Get-Date).AddDays(-5) }


# List Items in the Downloads folder with a size greater than a 100 Megabytes

Get-ChildItem -Recurse "$HOME\Downloads" | 
        Where-Object Length -gt 100mb | Select-Object -Property Name, LastWriteTime, Length |
                Format-List
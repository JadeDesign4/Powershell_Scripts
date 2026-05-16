 # 1. Create a Variable to store the path in

$path = "me\*.ps1"

if (Test-Path -Path $path -PathType Leaf) {
    Write-Output "PowerShell Script files exist in $path ✅"
} else {
    Write-Output "No Script files here"
}

# 2. Get Service that's Running & Arrange them in a list format
#Get-Service | Where-Object { $_.Status -eq "Running" } | Format-List -Property *

# 3. Create a New-Item
$PATH = "$HOME\me\shell*"
New-Item -Path $PATH -Name "prank 🥲.txt" -ItemType File -Value "You Fell For it 😆" 2> err.txt

# 4. Removing Items
Remove-Item -Path "$PATH\prank 🥲.txt" -Verbose

# 5. Get-ComputerInfo & Drive/Storage space
Get-ComputerInfo; Get-PSDrive | format-list -Property * 

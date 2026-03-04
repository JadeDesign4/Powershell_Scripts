# Create Files in the directory

$Path = "~\Documents"

# Conditional to verify if path exist

if (Test-Path $path -PathType Container) {
	Write-Output "Folder Exists"
} else {
	New-Item -ItemType Directory $Path
}

# Creating files in the Directory
	
	for ($i = 1; $i -le 12; $i++) {
		New-Item -ItemType File "$Path\day$i.txt"
}


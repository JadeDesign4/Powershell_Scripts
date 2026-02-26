# Create Files in the directory

$Path = "C:\Users\Public\Documents\Code"

# If the subdirectory 'Code' doesn't exist, Create the folder
# We're using Frontend Development files for an example
# Create a Folder for Html, CSS & JS

if (Test-Path $path) {
	Write-Output "Folder Exists"
} else {
	New-Item -ItemType Directory $Path
}

  New-Item -ItemType Directory $Path\Html, $Path\CSS, $Path\JS # Creating the subfolders in Code Directory

# Creating files in the subfolders
	
	for ($i = 1; $i -le 12; $i++) {
		New-Item -ItemType File "$Path\Html\index$i.html", "$Path\CSS\style$i.css", "$Path\JS\script$i.js"
}


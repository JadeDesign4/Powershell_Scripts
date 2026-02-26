# Script to create a directory Named Public in the User directory

$targetDir="C:\Users\GG\Public"

if (Test-Path $targetDir -PathType Container) {
	"Folder exists"	
} else {
	New-Item -ItemType Directory "C:\Users\GG\Public"
}
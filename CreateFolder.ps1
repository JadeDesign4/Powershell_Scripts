$path = "~" # Replace the path to your target directory
$target = "~\scripts"

if (Test-Path $path -PathType Container){
	Write-Output "Directory: $path Exists";
	New-Item -ItemType Directory $target
} else {
	Write-Output "Oops! Looks like you need to change the path..."
}

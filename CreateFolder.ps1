$path = "C:\Users\Public\Documents\powershellScripts" # Replace the path to your target directory

if (Test-Path $path -PathType Container){
	"Directory: $path Exists"
} else {
	New-Item -ItemType Directory $path
}

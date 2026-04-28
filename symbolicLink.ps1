# How to create a symbolic link windows

# Variables
# The Folder you want to make a link to
target="$USER\Downloads"

# The New Link Folder
New_Destination="$USER\me"

# 1. Using 'New-Item' command
New-Item -ItemType SymbolicLink -Path "$USER\me" -Target "$target"

# 2. Using mklink
# mklink /D "Path\To\New\Link" "Path\To\Original\Folder"

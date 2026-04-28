# 1. Define the path and the user
$Path = "$HOME"
$User = '$env:USERNAME'

# 2. Get the current ACL of the folder
$Acl = Get-Acl $Path

# 3. Define the new permission rule
# Arguments: (User, Rights, Inheritance, Propagation, Type)
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($User, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")

# 4. Add the rule to the ACL object
$Acl.SetAccessRule($Ar)

# 5. Apply the modified ACL back to the folder
Set-Acl $Path $Acl
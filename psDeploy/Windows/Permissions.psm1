
<#
.Synopsis
Gives a user permissions on a given folder
#>
function Set-FolderPermissions
{
    param
    (
        [string] $Path = $(throw "Must provide the folder path"),
        [string] $Username = $(throw "Must provide the user name"),
        [System.Security.AccessControl.FileSystemRights] $Permission = $(throw "Must provide the permission, ex: Read"),
        [System.Security.AccessControl.AccessControlType] $Modifier = $(throw "Must provide the modifier, ex: Allow")
    )
    
    $acl = Get-Acl $Path
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $Username, $Permission, $Modifier
    $acl.SetAccessRule($accessRule)
    Set-Acl -Path $Path -AclObject $acl
    
    Write-Output "Set $Modifier $Permission permission on '$Path' for '$Username'"
}


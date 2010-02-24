<#
.Synopsis
Adds a user to a local user group
#>
function Add-UserToGroup
{
    param
    (
        [string] $Username = $(throw "Must provide the user name"),
        [string] $Group = $(throw "Must provide the group name")
    )
    
    $computer = $env:computername
    $groupObj = [ADSI]"WinNT://$computer/$Group,group"
    
    # Check if the user is already part of the group
    $existingUser = $groupObj.Members() | Where { [string] $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null) -eq $Username }
     
    if ($existingUser -eq $null)
    {
        $groupObj.Add("WinNT://$Username")
        Write-Output "Added user '$Username' to group '$Group'"
    }
    else
    {
        Write-Output "User '$Username' is already part of group '$Group'"
    }
}

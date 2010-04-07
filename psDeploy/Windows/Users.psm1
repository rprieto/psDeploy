<#
.Synopsis
Creates a new local user
#>
function New-LocalUser
{
    param
    (
        [string] $Name = $(throw 'Must provide a username'),
        [string] $Password = $(throw 'Must provide a password')
    ) 
    
    $hostname = hostname   
    $computer = [adsi] "WinNT://$hostname"  
    
    $existingUser = $computer.psbase.children | Where { $_.Name -eq $Name }
      
    if ($existingUser -eq $null)
    {
        $userObj = $computer.Create("User", $Name)   
    
        $userObj.Put("description", "$Name")
        $userObj.SetInfo()
		$userObj.SetPassword($Password)
        $userObj.SetInfo()
        $userObj.psbase.invokeset("AccountDisabled", "False")
        $userObj.SetInfo()
    
        Write-Output "Created user '$Name'"
    }
    else
    {
        Write-Output "User '$Name' already exists"
    }
}

<#
.Synopsis
Deletes a local user
#>
function Remove-LocalUser
{
    param
    (
        [string] $Name = $(throw 'Must provide a username')
    ) 

    $hostname = hostname   
    $computer = [adsi] "WinNT://$hostname"  
    
    $existingUser = $computer.psbase.children | Where { $_.Name -eq $Name }
    
    if ($existingUser -eq $null)
    {
        Write-Output "Could not find user '$Name' to delete"
    }
    else
    {
        $computer.psbase.children.remove($existingUser)
        Write-Output "Deleted user '$Name'"
    }
}

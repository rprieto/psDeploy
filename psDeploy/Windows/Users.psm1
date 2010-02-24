<#
.Synopsis
Creates a new local user
#>
function New-User
{
    param
    (
        [string] $Name = $(throw 'Muse provide a username'),
        [string] $Password = $(throw 'Muse provide a password')
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

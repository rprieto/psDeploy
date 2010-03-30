<#
.Synopsis
Deletes an existing service. Careful, there is no confirmation before deleting.
#>
function Remove-Service
{
    param
    (
        [string] $Name = $(throw 'Must provide a service name'),
    ) 
    
	$svc = gwmi win32_service -filter "name='$Name'"
	
	if ($svc -ne $null)
	{
		$svc.delete()
		Write-Output "Deleted service '$Name'"
	}
	else
	{
		Write-Output "Could not find service '$Name' to delete"
	}
}



<#
.Synopsis
Changes an existing service username / password
#>
function Set-ServiceCredentials
{
    param
    (
        [string] $Name = $(throw 'Must provide a service name'),
        [string] $Username = $(throw "Must provide a username"),
        [string] $Password = $(throw "Must provide a password")
    ) 
    
    
    $svc = gwmi win32_service -filter "name='$Name'"
	
	if ($svc -ne $null)
	{
		$service.change($null, $null, $null, $null, $null, $null, $Username, $Password, $null, $null, $null) | out-null
		Write-Output "Credentials changed for service '$Name'"
	}
	else
	{
		Write-Output "Could not find service '$Name' for which to change credentials"
	}
}
<#
.Synopsis
Deletes an existing service. Careful, there is no confirmation before deleting.
#>
function Remove-Service
{
    param
    (
        [string] $Name = $(throw 'Must provide a service name')
    ) 
    
	$service = gwmi win32_service -filter "name='$Name'"
	
	if ($service -ne $null)
	{
		$service.delete()
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
    
    
    $service = gwmi win32_service -filter "name='$Name'"
	
	if ($service -ne $null)
	{
		$service.change($null, $null, $null, $null, $null, $null, $Username, $Password, $null, $null, $null) | out-null
		Write-Output "Credentials changed for service '$Name'"
	}
	else
	{
		Write-Output "Could not find service '$Name' for which to change credentials"
	}
}
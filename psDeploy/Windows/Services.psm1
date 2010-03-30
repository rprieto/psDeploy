<#
.Synopsis
Deletes an existing service. Careful, there is no confirmation before deleting.
#>
function Remove-Service
{
    param
    (
        [string] $Name = $(throw 'Muse provide a service name'),
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

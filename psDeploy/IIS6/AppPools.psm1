

<#
.Synopsis
Starts the app pool
#>
function Start-AppPool
{
    param
    (
        [string] $Name = $(throw "Must provide an app pool name")
    )
    
    Assert-II6Support
    
	$appPool = Get-WmiObject -Namespace "root\MicrosoftIISv2" -class IIsApplicationPool -Filter "Name ='W3SVC/APPPOOLS/$Name'"
	
    if ($appPool)
    {
        $appPool.Start()
        Write-Output "Started application pool '$Name'"
    }
    else
    {
        Write-Output "Could not find application pool '$Name' to start"
    }
}


<#
.Synopsis
Stops the app pool
#>
function Stop-AppPool
{
    param
    (
        [string]$Name = $(throw "Must provide an app pool name")
    )
    
    Assert-II6Support
    
	$appPool = Get-WmiObject -Namespace "root\MicrosoftIISv2" -class IIsApplicationPool -Filter "Name ='W3SVC/APPPOOLS/$Name'"
    
	if ($appPool)
    {
        $appPool.Stop()
        Write-Output "Stopped application pool '$Name'"
    }
    else
    {
        Write-Output "Could not find application pool '$Name' to stop"
    }
}


    
<#
.Synopsis
Creates an app pool
#>
function New-AppPool
{
    param
    (
        [string] $Name = $(throw "An AppPool name must be specified"),
        [bool] $PingingEnabled = $false,
        [string] $Username = 'NetworkService',
        [string] $Password = $null
    )

    Assert-II6Support

	$appPoolSettings = [wmiclass] 'root\MicrosoftIISv2:IISApplicationPoolSetting'
	$newPool = $appPoolSettings.PSBase.CreateInstance()
	
	$newPool.Name = "W3SVC/AppPools/" + $Name
	#$newPool.ManagedPipelineMode = 0 #Integrated
	#$newPool.PeriodicRestartTime = 0
	#$newPool.IdleTimeout = 0 # We may want to set this to 0 in production to prevent it from shutting down when things are quiet
	#$newPool.MaxProcesses = 2 # This changes the default to a web garden situation
    
    if ($Username -eq 'NetworkService')
    {
        $newPool.AppPoolIdentityType = 2
    }
    else    
    {
        $newPool.AppPoolIdentityType = 3
    	$newPool.WAMUsername = $Username
        $newPool.WAMUserPass = $Password
    }
    
	$newPool.PingingEnabled = $PingingEnabled #This is required for development debugging purposes

	# Call GetType() first so that Put does not fail.
	# http://blogs.msdn.com/powershell/archive/2008/08/12/some-wmi-instances-can-have-their-first-method-call-fail-and-get-member-not-work-in-powershell-v1.aspx
	# Write-Warning 'Ignore the next error if it says: Exception calling GetType'
	[Void]$newPool.GetType()
	
	[Void]$newPool.Put()
	if (!$?)
    {
        throw "Failed to create $Name"
    }
    else
    {
        Write-Output "Created application pool '$Name'"
    }
}



<#
.Synopsis
Deletes an app pool from IIS
Note: any website in this application pool has to be deleted first
#>
function Remove-AppPool
{
    param
    (
        [string] $Name = $(throw "Must provide an app pool name")
    )
    
    Assert-II6Support
    
	$appPool = Get-WmiObject -Namespace "root\MicrosoftIISv2" -class IIsApplicationPool -Filter "Name ='W3SVC/APPPOOLS/$Name'"
    
	if ($appPool)
    {
        Try
        {
            $appPool.Delete()
            Write-Output "Deleted application pool '$Name'"
        }
        Catch [System.Management.Automation.MethodInvocationException]
        {
            # The exception that is normally thrown is very generic / vague
            throw "Failed deleting application pool '$Name'. Check that it does not host any website or application."
        }
    }
    else
    {
        Write-Output "Could not find application pool '$Name' to delete"
    }
}




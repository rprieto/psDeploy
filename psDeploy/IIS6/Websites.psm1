

<#
.Synopsis
Starts the website
#>
function Start-WebSite
{
    param
    (
        [string] $Name = $(throw "Must provide a website name")
    )

    Assert-II6Support

    $webServerSetting = Get-WmiObject -Namespace 'root\MicrosoftIISv2' -Class IISWebServerSetting -Filter "ServerComment = '$Name'"
    
    if ($webServerSetting)
    {
        $webServers = Get-WmiObject -Namespace 'root\MicrosoftIISv2' -Class IIsWebServer
        $targetServer = $webServers | Where-Object { $_.Name -eq $webServerSetting.Name }
        $targetServer.Start()
        
        Write-Output "Started website '$Name'"
    }
    else
    {
        Write-Output "Could not find website '$Name' to start"
    }
}


<#
.Synopsis
Starts the website
#>
function Stop-WebSite
{
    param
    (
        [string] $Name = $(throw "Must provide a website name")
    )

    Assert-II6Support

    $webServerSetting = Get-WmiObject -Namespace 'root\MicrosoftIISv2' -Class IISWebServerSetting -Filter "ServerComment = '$Name'"
    
    if ($webServerSetting)
    {
        $webServers = Get-WmiObject -Namespace 'root\MicrosoftIISv2' -Class IIsWebServer
        $targetServer = $webServers | Where-Object { $_.Name -eq $webServerSetting.Name }
        $targetServer.Stop()
        
        Write-Output "Stopped website '$Name'"
    }
    else
    {
        Write-Output "Could not find website '$Name' to stop"
    }
}


<#
.Synopsis
Deletes the website
#>
function Remove-WebSite
{
    param
    (
        [string] $Name = $(throw "Must provide a Site Name")
    )

    Assert-II6Support

	$webServerSetting = Get-WmiObject -Namespace "root\MicrosoftIISv2" -Class IISWebServerSetting -Filter "ServerComment = '$Name'"
    
	if ($webServerSetting)
    {
        $webServerSetting.Delete()
        Write-Output "Deleted website '$Name'"
    }
    else
    {
        Write-Output "Could not find website '$Name' to delete"
    }
}


<#
.Synopsis
Creates a new website
#>
function New-WebSite
{
    param
    (
        [string] $Name = $(throw "Must provide a Site Name"),
	    [string] $Path = $(throw "Must provide a physical path"),
	    [string] $AppPool = $(throw "Must provide an App Pool name"),
	    [string] $Ip = $null,
	    [string] $Port = "80",
        [string] $HostHeader = $null,
        [string] $DefaultDoc = $null,
	    [switch] $DefaultAccess
    )

    Assert-II6Support

	$service = Get-WmiObject -namespace "root\MicrosoftIISv2" -class "IIsWebService"

	$bindingClass = [wmiclass]'root\MicrosoftIISv2:ServerBinding'
	$bindings = $bindingClass.CreateInstance()
	$bindings.IP = $Ip
	$bindings.Port = $Port
	$bindings.Hostname = $HostHeader
	
	$webSite = $service.CreateNewSite($Name, $bindings, $Path)

	$webServerSetting = Get-WmiObject -Namespace 'root\MicrosoftIISv2' -Class IISWebServerSetting -Filter "ServerComment = '$Name'"

	$webServerSetting.AppPoolId = $AppPool
	$webServerSetting.ServerAutoStart = $true
	
	if ($defaultDoc)
	{
		$webServerSetting.EnableDefaultDoc = $true
		$webServerSetting.DefaultDoc = $DefaultDoc	
	}
	
	if ($DefaultAccess)
	{
		$webServerSetting.AuthAnonymous = $true
		$webServerSetting.AccessRead = $true
		$webServerSetting.AccessScript = $true
	}
	
	[Void]$webServerSetting.Put()
	
	# Set implicit ROOT application properties
	$rootVirtualDirName = $webServerSetting.Name + '/ROOT'
	$virtualDirSetting = Get-WmiObject -Namespace 'root\MicrosoftIISv2' -Class IISWebVirtualDirSetting -Filter "Name = '$rootVirtualDirName'"
	$virtualDirSetting.AppPoolId = $AppPool
	[Void]$virtualDirSetting.Put()
	
	Write-Output "Created new website '$Name' pointing to '$Path'"
}





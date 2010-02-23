<#
.Synopsis
Checks that WMI is accessible. Please call this before calling any other functions in this module
#>
function Assert-WmiProvider
{
	[wmiclass] 'root/MicrosoftIISv2:IIsWebServer' > $null
	if (!$?)
	{
		throw "The IIS WMI Provider does not appear to be installed on the target computer."
	}
}

<#
.Synopsis
Deletes the app pool
#>
function Remove-AppPool
{
    param(  [string]$Name = $(throw "Must provide an app pool name")
    )
    
	$appPool = Get-WmiObject -Namespace "root\MicrosoftIISv2" -class IIsApplicationPool -Filter "Name ='W3SVC/APPPOOLS/$Name'"
	if ($appPool)
    {
        $appPool.Delete()
    }
}


<#
.Synopsis
Stops the app pool
#>
function Stop-AppPool
{
    param(  [string]$appPoolName = $(throw "Must provide an app pool name")
    )
    
	$appPool = Get-WmiObject -Namespace "root\MicrosoftIISv2" -class IIsApplicationPool -Filter "Name ='W3SVC/APPPOOLS/$appPoolName'"
	if ($appPool)
    {
        $appPool.Stop()
    }
}


<#
.Synopsis
Starts the app pool
#>
function Start-AppPool
{
    param(  [string]$Name = $(throw "Must provide an app pool name")
    )
    
	$appPool = Get-WmiObject -Namespace "root\MicrosoftIISv2" -class IIsApplicationPool -Filter "Name ='W3SVC/APPPOOLS/$Name'"
	if ($appPool)
    {
        $appPool.Start()
    }
}

    
<#
.Synopsis
Creates an app pool
#>
function New-AppPool
{
    param(  [string]$Name = $(throw "An AppPool name must be specified"),
            [bool]$PingingEnabled = $false,
            [string]$Username = 'NetworkService',
	        [string]$Password = $null
    )

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
	if (!$?) { throw "Failed to create $Name" }
}


<#
.Synopsis
Creates an application
#>
function New-Application
{
    param(  [string]$newApplication = $(throw "Must provide an Application Name"),
	        [string]$newVDirPath = $(throw "Must provide a path"),
	        [string]$newPoolName = $(throw "Must specify an AppPool")
	)
	
	# Settings
	$newVDirName = "W3SVC/1/ROOT/" + $newApplication
	
	#Switch the Website to .NET 2.0
	#C:\windows\Microsoft.NET\Framework\v2.0.50727\aspnet_regiis.exe -sn W3SVC/

	# Ensure the directory exists 
	if (!(Test-Path -Path $newVDirPath -PathType Container)) { New-Item -Path $newVDirPath -Type Directory }
	
	$virtualDirSettings = [wmiclass] "root\MicrosoftIISv2:IIsWebVirtualDirSetting"
	$newVDir = $virtualDirSettings.CreateInstance()
	$newVDir.Name = $newVDirName
	$newVDir.Path = $newVDirPath
	$newVDir.EnableDefaultDoc = $False
	$newVDir.Put()
	# Do it a few times if it fails as there is a bug with Powershell/WMI
	$newVDir.Put();
	if (!$?) { $newVDir.Put() }
	
	# Create the application on the virtual directory
	$vdir = Get-WmiObject -namespace "root\MicrosoftIISv2" -class "IISWebVirtualDir" -filter "Name = '$newVDirName'"
	$vdir.AppCreate3(2, $newPoolName)
	
	# Updated the Friendly Name of the application
	$newVDir.AppFriendlyName = $newApplication
	$newVDir.Put()
}


<#
.Synopsis
Deletes the virtual directory
#>
function Remove-VirtualDirectory
{
    param(  [string]$applicationName = $(throw "Must provide app name")
        )
        
    $vdtest= [adsi]"IIS://localhost/w3svc/1/Root/$applicationName"
    $vdtest.AppDeleteRecursive()
}


<#
.Synopsis
Starts the website
#>
function Start-WebSite
{
    param(  [string]$Name = $(throw "Must provide a Site Name")
    )

    # IIS 6 version
    $webServerSetting = Get-WmiObject -Namespace 'root\MicrosoftIISv2' -Class IISWebServerSetting -Filter "ServerComment = '$Name'" 
    $webServers = Get-WmiObject -Namespace 'root\MicrosoftIISv2' -Class IIsWebServer
    $targetServer = $webServers | Where-Object { $_.Name -eq $webServerSetting.Name }
    $targetServer.Start()

	# IIS 7 version
	#$webSite = Get-WmiObject -Namespace "root/WebAdministration" -Class Site -Filter "Name = '$siteName'"
	#if ($webSite) {
	#	Write-Debug ('Starting ' + $webSite.Name)
	#	$webSite.Start()
	#}
}

#function StopWebsite([string]$siteName = $(throw "Must specify a site name"))
#{
#    $server = "servername"
#    $siteName = "Default Web Site"
#    $iis = [ADSI]"IIS://$server/W3SVC"
#    $site = $iis.psbase.children | where { $_.keyType -eq "IIsWebServer" -AND
#    $_.ServerComment -eq $siteName }
#    $site.serverstate=4
#    $site.setinfo()
#}


<#
.Synopsis
Deletes the website
#>
function Remove-WebSite
{
    param( [string]$Name = $(throw "Must provide a Site Name")
    )

	$webServerSetting = Get-WmiObject -Namespace 'root\MicrosoftIISv2' -Class IISWebServerSetting -Filter "ServerComment = '$Name'"
	if ($webServerSetting)
    {
        $webServerSetting.Delete()
    }
}


<#
.Synopsis
Creates a new website
#>
function New-WebSite
{
    param(  [string]$Name = $(throw "Must provide a Site Name"),
	        [string]$Path = $(throw "Must provide a physical path"),
	        [string]$AppPool = $(throw "Must provide an App Pool name"),
	        [string]$Ip = $null,
	        [string]$Port = "80",
	        [string]$HostHeader = $null,
	        [string]$DefaultDoc = $null,
	        [switch]$DefaultAccess
    )

	$service = Get-WmiObject -namespace "root\MicrosoftIISv2" -class "IIsWebService"

	$bindingClass = [wmiclass]'root\MicrosoftIISv2:ServerBinding'
	$bindings = $bindingClass.CreateInstance()
	$bindings.IP = $Ip
	$bindings.Port = $Port
	$bindings.Hostname = $HostHeader
	
	$webSite = $service.CreateNewSite($Name, $bindings, $Path)

	$webServerSetting = Get-WmiObject -Namespace 'root\MicrosoftIISv2' -Class IISWebServerSetting -Filter "ServerComment = '$Name'"
	# This sets the applicationDefaults for the site 
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
	
	Write-Debug ('Created {0}' -f $webServerSetting.Name)
}


<#
.Synopsis
Enables SSL for the website
#>
function Enable-SiteSelfSSL
{
    param(	[string]$siteName = $(throw "Must provide a Site Name"),
	        [string]$hostName = $(throw "Must provide a Host Name")
	)
	
	$scriptFolder = & { (Split-Path $MyInvocation.ScriptName -Parent) }
	$projectFolder = (Get-Item $scriptFolder).Parent.Parent.FullName
	$selfSslExe = (Join-Path $projectFolder 'tools\SelfSSL\selfssl.exe')
	$webSite = Get-WmiObject -Namespace "root/WebAdministration" -Class Site -Filter "Name = '$siteName'"
	if ($webSite) {
		
		$startInfo = New-Object Diagnostics.ProcessStartInfo($selfSslExe)
		$startInfo.UseShellExecute = $false
		($startInfo.Arguments = ('/T /N:cn={0} /V:1000 /S:{1} /Q' -f $hostName,$webSite.Id))
		$process = [Diagnostics.Process]::Start($startInfo)
		$process.WaitForExit()
		$exitCode = $process.ExitCode
	} else { throw "$siteName not found" }
}



<#
.Synopsis
Creates a virtual directory
#>
function New-VirtualDirectory
{
    param(	[string]$siteName = $(throw "Must provide a Site Name"),
	        [string]$vDirName = $(throw "Must provide a Virtual Directory Name"),
	        [string]$path = $(throw "Must provide a local filesystem path")
	)
	
	$iisWmiObj = Get-WmiObject -Namespace 'root\MicrosoftIISv2' -Class IISWebServerSetting -Filter "ServerComment = '$siteName'"

	$objIIS = new-object System.DirectoryServices.DirectoryEntry("IIS://localhost/" + $iisWmiObj.Name + "/Root")
	$children = $objIIS.psbase.children
	$vDir = $children.add($vDirName,$objIIS.psbase.SchemaClassName)
	$vDir.psbase.CommitChanges()
	$vDir.Path = $path
	$vDir.defaultdoc = "Default.htm"
	$vDir.psbase.CommitChanges()
}


<#
.Synopsis
Creates a network virtual directory
#>
function New-UNCVirtualDirectory
{
    param(  [string]$siteName = $(throw "Must provide a Site Name"),
	        [string]$vDirName = $(throw "Must provide a Virtual Directory Name"),
	        [string]$uncPath = $(throw "Must provide a UNC path"),
	        [string]$uncUserName = $(throw "Must provide a UserName"),
	        [string]$uncPassword = $(throw "Must provide a password")
	)
	
    $iisWebSite = Get-WmiObject -Namespace 'root\MicrosoftIISv2' -Class IISWebServerSetting -Filter "ServerComment = '$siteName'"

	$objIIS = new-object System.DirectoryServices.DirectoryEntry("IIS://localhost/" + $iisWebSite.Name + "/Root")
	$children = $objIIS.psbase.children
	$vDir = $children.add($vDirName,$objIIS.psbase.SchemaClassName)
	$vDir.psbase.CommitChanges()
	$vDir.Path = $uncPath
	$vDir.UNCUserName = $uncUserName
	$vDir.UNCPassword = $uncPassword
	$vDir.psbase.CommitChanges()
}


<#
.Synopsis
What does this do?
#>
function New-UNCVirtualDirectory2
{
    param(	[string]$siteName = $(throw "Must provide a Site Name"),
	        [string]$vDirName = $(throw "Must provide a Virtual Directory Name"),
	        [string]$uncPath = $(throw "Must provide a UNC path"),
	        [string]$uncUserName = $(throw "Must provide a UserName"),
	        [string]$uncPassword = $(throw "Must provide a password")
	)
	
	$iisWebSite = Get-WmiObject -Namespace 'root\MicrosoftIISv2' -Class IISWebServerSetting -Filter "ServerComment = '$siteName'"

	$virtualDirSettings = [wmiclass] "root\MicrosoftIISv2:IIsWebVirtualDirSetting"
	$newVDir = $virtualDirSettings.CreateInstance()
	$newVDir.Name = ($iisWebSite.Name + '/ROOT/' + $vDirName)
	$newVDir.Path = $uncPath
	$newVDir.UNCUserName = $uncUserName
	$newVDir.UNCPassword = $uncPassword
	$newVDir.EnableDefaultDoc = $False
	$newVDir.Put()
	# Do it a few times if it fails as there is a bug with Powershell/WMI
	$newVDir.Put();
	if (!$?) { $newVDir.Put() }
}

	
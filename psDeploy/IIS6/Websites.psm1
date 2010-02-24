

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

    $webServerSetting = Get-WmiObject -Namespace 'root\MicrosoftIISv2' -Class IISWebServerSetting -Filter "ServerComment = '$Name'" 
    $webServers = Get-WmiObject -Namespace 'root\MicrosoftIISv2' -Class IIsWebServer
    $targetServer = $webServers | Where-Object { $_.Name -eq $webServerSetting.Name }
    $targetServer.Start()
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
    param
    (
        [string]$Name = $(throw "Must provide a Site Name")
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
    param
    (
        [string] $siteName = $(throw "Must provide a Site Name"),
	    [string] $hostName = $(throw "Must provide a Host Name")
	)
	
	$scriptFolder = & { (Split-Path $MyInvocation.ScriptName -Parent) }
	$projectFolder = (Get-Item $scriptFolder).Parent.Parent.FullName
	$selfSslExe = (Join-Path $projectFolder 'tools\SelfSSL\selfssl.exe')
	$webSite = Get-WmiObject -Namespace "root/WebAdministration" -Class Site -Filter "Name = '$siteName'"
	
    if ($webSite)
    {		
		$startInfo = New-Object Diagnostics.ProcessStartInfo($selfSslExe)
		$startInfo.UseShellExecute = $false
		($startInfo.Arguments = ('/T /N:cn={0} /V:1000 /S:{1} /Q' -f $hostName,$webSite.Id))
		$process = [Diagnostics.Process]::Start($startInfo)
		$process.WaitForExit()
		$exitCode = $process.ExitCode
	}
    else
    {
        throw "$siteName not found"
    }
}





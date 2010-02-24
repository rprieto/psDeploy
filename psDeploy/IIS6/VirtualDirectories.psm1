
<#
.Synopsis
Creates a virtual directory
#>
function New-VirtualDirectory
{
    param
    (
    	[string] $siteName = $(throw "Must provide a Site Name"),
	    [string] $vDirName = $(throw "Must provide a Virtual Directory Name"),
	    [string] $path = $(throw "Must provide a local filesystem path")
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
    param
    (
    	[string] $siteName = $(throw "Must provide a Site Name"),
        [string] $vDirName = $(throw "Must provide a Virtual Directory Name"),
	    [string] $uncPath = $(throw "Must provide a UNC path"),
	    [string] $uncUserName = $(throw "Must provide a UserName"),
	    [string] $uncPassword = $(throw "Must provide a password")
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

	

<#
.Synopsis
Deletes the virtual directory
#>
function Remove-VirtualDirectory
{
    param
    (
        [string] $applicationName = $(throw "Must provide app name")
    )
        
    $vdtest= [adsi]"IIS://localhost/w3svc/1/Root/$applicationName"
    $vdtest.AppDeleteRecursive()
}


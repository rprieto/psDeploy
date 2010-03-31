
<#
.Synopsis
Creates a virtual directory
#>
function New-IIS6VirtualDirectory
{
    param
    (
    	[string] $Website = $(throw "Must provide a website ame"),
	    [string] $Name = $(throw "Must provide a virtual directory Name"),
	    [string] $Path = $(throw "Must provide a local filesystem path")
	)
	
    Assert-II6Support
    
	$iisWmiObj = Get-WmiObject -Namespace 'root\MicrosoftIISv2' -Class IISWebServerSetting -Filter "ServerComment = '$Website'"

	$objIIS = new-object System.DirectoryServices.DirectoryEntry("IIS://localhost/" + $iisWmiObj.Name + "/Root")
	$children = $objIIS.psbase.children
    
	$vDir = $children.add($Name, "IISWebVirtualDir")
	$vDir.psbase.CommitChanges()
	$vDir.Path = $Path
	$vDir.defaultdoc = "Default.htm"
	$vDir.psbase.CommitChanges()
    
    Write-Output "Created virtual directory '$Name' in website '$Website'"
}


<#
.Synopsis
Deletes the virtual directory
#>
function Remove-IIS6VirtualDirectory
{
    param
    (
        [string] $Website = $(throw "Must provide a website name"),
        [string] $Name = $(throw "Must provide a virtual directory name")
    )
    
    Assert-II6Support
    
    $websiteSettings = Get-WmiObject -Namespace 'root\MicrosoftIISv2' -Class IISWebServerSetting -Filter "ServerComment = '$Website'"
    $entry = new-object System.DirectoryServices.DirectoryEntry("IIS://localhost/" + $websiteSettings.Name + "/Root")
    
    $directories = $entry.psbase.children
    
    Try
    {
        $virtualDir = $directories.find($Name, "IIsWebVirtualDir")
    }
    Catch
    {
        Write-Output "Could not find virtual directory '$Name' to delete"
        return
    } 
    
    $directories.Remove($virtualDir)
    Write-Output "Deleted virtual directory '$Name' from website '$Website'"
}




<#
.Synopsis
Creates a network virtual directory
#>
<#
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
#>

<#
.Synopsis
What does this do?
#>
<#
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
#>
	


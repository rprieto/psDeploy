<#
    psDeploy - A Powershell deployment automation library
    Find the latest version and documentation at http://github.com/rprieto/psDeploy
#>


$currentDir = Split-Path $MyInvocation.MyCommand.Path
$modules = Get-ChildItem -Path $currentDir -Recurse -Include "*.psm1" -Exclude "psDeploy.psm1"
$modules | %{ Import-Module -Name $_ -Force }



<#
.Synopsis
Checks that all the dependencies are available.
Please call this before calling any other cmdlets in psDeploy
#>
function Assert-PsDeploySupported
{
	[wmiclass] 'root/MicrosoftIISv2:IIsWebServer' > $null
	if (!$?)
	{
		throw "The IIS WMI Provider does not appear to be installed"
	}
}



<#
.Synopsis
Initialises standard deployment settings
#>
function Initialize-PsDeploy
{
    param
    (
        [switch] $FailFast,
        [string] $LogPath = $null
    ) 

    if ($FailFast)
    {
	   $ErrorActionPreference = 'Stop'
    }
    
    if ($LogPath -ne $null)
    {
        Try
        {
            $date = Get-Date -Format "yyyy-MM-dd-hh\hmm\mss\s"
            Start-Transcript -Path "$LogPath\$date.log"
        }
        Catch [System.Management.Automation.PSNotSupportedException]
        {
            Write-Output "Log transcripts are not available when running from the IDE"
        }
    }
}

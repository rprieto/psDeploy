Set-StrictMode -Version 2
$ErrorActionPreference = 'Stop' 

try
{
    Set-Location (Split-Path $MyInvocation.MyCommand.Path) 
    Import-Module .\psDeploy\psDeploy.psm1

    Start-Log -Name 'MyApp_' -AppendDate 
    
    #
    # Insert deployment steps here
    #

    Write-DeploymentSuccess 'My app name'
}
catch
{
    $_ | Write-Warning
    Write-DeploymentFailure 'My app name' 
}

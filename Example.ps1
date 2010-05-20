Set-StrictMode -Version 2
$ErrorActionPreference = 'Stop' 

try
{
    # Load modules 
    Set-Location (Split-Path $MyInvocation.MyCommand.Path) 
    Import-Module .\psDeploy\psDeploy.psm1

    # The actual install 
    Start-Log -Name 'MyApp_' -AppendDate 
    
    #Stop-Service -DisplayName "Event log"    

    # Finished!
    Write-DeploymentSuccess 'My app name'
}
catch
{
    $_ | Write-Warning
    Write-DeploymentFailure 'My app name' 
}

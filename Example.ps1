# Standard guards 
Set-StrictMode -Version 2.0 
$ErrorActionPreference = 'Stop' 
Trap [Exception] 
{ 
    Write-DeploymentFailure 'My app name' 
    break 
}

# Load modules 
Set-Location (Split-Path $MyInvocation.MyCommand.Path) 
Import-Module .\psDeploy\psDeploy.psm1

# The actual install 
Start-Log -Name 'MyApp_' -AppendDate 
New-IIS6AppPool -Name 'Temp'
Remove-IIS6AppPool -Name 'Temp'

# Finished!
Write-DeploymentSuccess 'My app name'

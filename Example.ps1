#
# Deployment init
#

$ErrorActionPreference = 'Stop'
Trap [Exception]
{
    Write-Warning "The deployment failed"
    break
}

#Import-Module psDeploy
Import-Module -Name "C:\Romain\github\psDeploy\master\psDeploy\psDeploy.psm1" -Force 
Set-StrictMode -Version 2.0


#
# Deployment steps
#

Start-Log -Path "C:\DeploymentLogs" -Name "Install_" -AppendDate

New-IIS6AppPool -Name 'Temp'
Remove-IIS6AppPool -Name 'Temp'

Expand-Zip -File "C:\Temp\package.zip" -Destination "C:\Temp\Package" -CleanDestinationFirst
Update-Service -Name "StuffPool" -NewVersionPath "C:\Dump\1.0"

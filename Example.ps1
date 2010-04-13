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


#
# Deployment steps
#

Start-Log -Path "C:\DeploymentLogs" -Prefix "Install_" -UseDate

New-IIS6AppPool -Name 'Temp'
Remove-IIS6AppPool -Name 'Temp'

Expand-Zip -File "C:\Temp\package.zip" -Destination "C:\Temp\Package" -CleanDestinationFirst
Update-Service -Name "StuffPool" -NewVersionPath "C:\Dump\1.0"

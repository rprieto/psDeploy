#
# Deployment init
#

Import-Module psDeploy
#Import-Module -Name "C:\Romain\github\psDeploy\psDeploy\psDeploy.psm1" -Force 
Assert-PsDeploySupported
Initialize-PsDeploy -FailFast -LogPath "C:\DeploymentLogs"

#
# Deployment steps
#

New-IIS6AppPool -Name 'Temp'
Remove-IIS6AppPool -Name 'Temp'


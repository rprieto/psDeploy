Set-StrictMode -Version 2
$ErrorActionPreference = 'Stop' 

try
{
    Set-Location (Split-Path $MyInvocation.MyCommand.Path) 
    Import-Module .\psDeploy\psDeploy.psm1

    Start-Log -Name 'MyApp_' -AppendDate 
    
    #
    # Insert deployment steps here
    
    Stop-IIS6AppPool -Name "MyPool"
    New-LocalUser -Name "Bob" -Password "123456"
    Expand-Zip -File "C:\Builds\Version3.zip" -Destination "C:\MyService" -CleanDestinationFirst
    New-ScheduledTask -Name "MyTask" -Path "C:\Task.exe" -Every 2 -Weeks -On "Mon,Wed" -At 18:30

    #
    #

    Write-DeploymentSuccess 'My app name'
}
catch
{
    $_ | Write-Warning
    Write-DeploymentFailure 'My app name' 
}

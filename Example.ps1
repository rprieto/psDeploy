Set-StrictMode -Version 2
$ErrorActionPreference = 'Stop' 

Set-Location (Split-Path $MyInvocation.MyCommand.Path) 
Import-Module .\psDeploy\psDeploy.psm1 -Force


$psDeploy.Log.Name = 'Example2'
$psDeploy.Log.Journal = 'C:\Logs\Journal.txt'
$psDeploy.Log.Transcripts = 'C:\Logs\Transcripts'


deploy -transcript -journal -script {

    Write-Host "Doing stuff..."
    #Stop-Service 'Foo'

} -success {
    
    Write-Host "Let's start testing"

} -failure {

    Write-Host "Please check the logs"

}

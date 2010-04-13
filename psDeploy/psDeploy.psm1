<#
    psDeploy - A Powershell deployment automation library
    Find the latest version and documentation at http://github.com/rprieto/psDeploy
#>

Set-StrictMode -Version 2.0

$currentDir = Split-Path $MyInvocation.MyCommand.Path
$modules = Get-ChildItem -Path $currentDir -Recurse -Include "*.psm1" -Exclude "psDeploy.psm1"
$modules | %{ Import-Module -Name $_ -Force }


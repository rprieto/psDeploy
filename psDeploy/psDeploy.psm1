<#
    psDeploy - A Powershell deployment automation library
    Find the latest version and documentation at http://rprieto.github.com/psDeploy
#>

Set-StrictMode -Version 2.0

$currentDir = Split-Path $MyInvocation.MyCommand.Path

$modules = Get-ChildItem -Path $currentDir -Recurse -Include "*.psm1" -Exclude "psDeploy.psm1"
$modules | %{ Import-Module -Name $_ -Force }


<#
    Export members
#>

Export-ModuleMember -Variable psDeploy
Export-ModuleMember -Function deploy
Export-ModuleMember -Function Clear-FolderContents, New-Backup
Export-ModuleMember -Function Expand-Zip
Export-ModuleMember -Function Assert-II6Support
Export-ModuleMember -Function Start-IIS6AppPool, Stop-IIS6AppPool, New-IIS6AppPool, Remove-IIS6AppPool
Export-ModuleMember -Function New-IIS6VirtualDirectory, Remove-IIS6VirtualDirectory
Export-ModuleMember -Function Start-IIS6WebSite, Stop-IIS6WebSite, Remove-IIS6WebSite, New-IIS6WebSite
Export-ModuleMember -Function Start-UniqueTranscript, Stop-UniqueTranscript, Get-JournalEntry, Add-ToFile
Export-ModuleMember -Function Get-TotalRam, Get-DiskSize, Get-DiskFreeSpace
Export-ModuleMember -Function Add-UserToGroup, Remove-UserFromGroup
Export-ModuleMember -Function New-NetworkDrive
Export-ModuleMember -Function Set-FolderPermissions
Export-ModuleMember -Function Get-ScheduledTask, Start-ScheduledTask, Enable-ScheduledTask, Disable-ScheduledTask, New-ScheduledTask, Remove-ScheduledTask
Export-ModuleMember -Function Find-Service, Remove-Service, Set-ServiceCredentials, Update-Service
Export-ModuleMember -Function Get-SharedFolders, New-SharedFolder, Remove-SharedFolder
Export-ModuleMember -Function New-LocalUser, Remove-LocalUser

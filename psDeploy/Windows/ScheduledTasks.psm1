
<#
.Synopsis
Gets info about an existing scheduled task
#>
function Get-ScheduledTask
{
    param
    (
        [string] $Name = $(throw "Must provide a task name")
    )
	
    $tempCsv = [System.IO.Path]::GetTempFileName()
    
    Invoke-Expression "schtasks.exe /query /v /fo csv > $tempCsv"
    $found = Import-Csv -Path $tempCsv | Where { $_.TaskName -eq $Name }
    
    Remove-Item $tempCsv -Force
    
    return $found
}


<#
.Synopsis
Enables an existing scheduled task
#>
function Enable-ScheduledTask
{
    param
    (
        [string] $Name = $(throw "Must provide a task name")
    )
}


<#
.Synopsis
Disables an existing scheduled task
#>
function Disable-ScheduledTask
{
    param
    (
        [string] $Name = $(throw "Must provide a task name")
    )
}


<#
.Synopsis
Creates a new scheduled task
#>
function New-ScheduledTask
{
    param
    (
    	[string]$Name = $(throw "Must provide a task name"),
    	[string]$Path = $(throw "Must provide the path to the executable"),
    	[string]$RunAs = "System",
        
    	[string]$Schedule = "Monthly",
    	[string]$Modifier = "second",
    	[string]$Days = "SUN",
    	[string]$Months = '"MAR,JUN,SEP,DEC"',
    	[string]$StartTime = "13:00",
    	[string]$EndTime = "17:00",
    	[string]$Interval = "60"	
	)
    
	Write-Host "Computer: $ComputerName"
	$Command = "schtasks.exe /create /s $ComputerName /ru $RunAsUser /tn $TaskName /tr $TaskRun /sc $Schedule /mo $Modifier /d $Days /m $Months /st $StartTime /et $EndTime /ri $Interval /F"
	Invoke-Expression $Command
}


<#
.Synopsis
Deletes an existing scheduled task
#>
function Remove-ScheduledTask
{
    param
    (
        [string] $Name = $(throw "Must provide a task name")
    )
}


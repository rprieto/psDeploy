function Assert-ValidSwitch
{
    param
    (
        [string] $Value,
        [object[]] $AvailableOptions
    )
    
    $found = $AvailableOptions -contains $Value
    if (!$found)
    {
        throw New-Object System.ArgumentException "Invalid value '$Value', should be one of '$AvailableOptions'"
    }
}



<#
.Synopsis
Gets info about an existing scheduled task
Returns either $null or a full object (ex: $task.TaskName, $task."Task To Run")
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
Forces an existing scheduled task to run
#>
function Run-ScheduledTask
{
    param
    (
        [string] $Name = $(throw "Must provide a task name")
    )
    
    Invoke-Expression "schtasks.exe /run /tn ""$Name"""
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
    
    Invoke-Expression "schtasks.exe /run /tn ""$Name"" /enable"
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
    
    Invoke-Expression "schtasks.exe /run /tn ""$Name"" /disable"
}


<#
.Synopsis
Creates a new scheduled task.
The following schedule types are acceptable:

-RepeatMinutes -Every 2
-RepeatHourly -Every 5
-RepeatDaily -Every 1
-RepeatWeekly -Every 2
-RepeatMonthly -Every 3
-RepeatMonthly "Jan, Feb" -OnTheSecond "Mon"


-Repeat "Daily" -Every 2 -StartTime "21:00"
-Repeat "Monthly" -Every 1 -StartTime "21:00"
-Repeat "Monthly" -OnThe "Second" -Days "Tue" -Months "Jan,Feb" -StartTime "21:00" 
-OnceOnThe "17/04/2010" -StartTime "21:00" 
-AtStartup
-AtLogon
-WhenIdle 15

The -Days and -Months parameters can also take "*" to mean all.
#>
function New-ScheduledTask
{
    param
    (
    	[string] $Name = $(throw "Must provide a task name"),
    	[string] $Path = $(throw "Must provide the path to the executable"),
        [DateTime] $StartTime = $null,
        [string] $Repeat = $null,
        [int] $Every = $null,
        [string] $OnThe = $null,
        [DateTime] $Once = $null,
        [string] $Days = $null,
        [string] $Months = $null,
        [switch] $OnStart = $null,
        [switch] $OnLogon = $null,
        [int] $WhenIdleFor = $null
	)
    
    $exclusiveSchedules = $Repeat -xor $Once -xor $OnStart -xor $OnLogon -xor $WhenIdleFor
    if (!$exclusiveSchedules)
    {
        throw New-Object System.ArgumentException "Parameters are not valid, please choose only one schedule type."
    }
    
    # Basic structure for calling schtasks
    $basicParams = "/create /tn ""$Name"" /tr ""$Path"""
    $scheduleParams = ""
    $additionalParams = ""
            
    if ($Repeat)
    {
        Assert-ValidSwitch -Value $Repeat -AvailableOptions "Minutes", "Hourly", "Daily", "Weekly", "Monthly"

        $time = $StartTime.ToString("HH:mm")

        if ($Days)
        {
            $additionalParams += " /d $Days"
        }
        
        if ($Months)
        {
            $additionalParams += " /m $Months"
        }

        if ($Repeat = "Monthly" -and $OnThe)
        {
            Assert-ValidSwitch -Value $OnThe -AvailableOptions "LastDay", "First", "Second", "Third", "Fourth", "Last"
            $scheduleParams = "$Repeat /mo $OnThe /st $time"
        }
        else
        {
            $scheduleParams = "$Repeat /mo $Every /st $time"
        }
        
        
    }
    elseif ($Once)
    {
        $date = $Once.ToString("MM/dd/yyyy")
        $time = $StartTime.ToString("HH:mm")
        $scheduleParams = "once /sd $date /st $time"
    }
    elseif ($OnStart)
    {
        $scheduleParams = "onstart"
    }
    elseif ($OnLogon)
    {
        $scheduleParams = "onlogon"
    }
    elseif ($WhenIdleFor)
    {
        $scheduleParams = "onidle /i $WhenIdleFor"
    }
    
    Invoke-Expression "schtasks.exe $basicParams /sc $scheduleParams $additionalParams /f"
}



<#
.Synopsis
Deletes an existing scheduled task.
Use the 'force' switch to delete a task even if it's currently running
#>
function Remove-ScheduledTask
{
    param
    (
        [string] $Name = $(throw "Must provide a task name"),
        [switch] $Force
    )
    
    if ($Force)
    {
        $params = "/f"
    }
    
    Invoke-Expression "schtasks.exe /delete /tn ""$Name"" $params"
}


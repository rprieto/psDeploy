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
function Start-ScheduledTask
{
    param
    (
        [string] $Name = $(throw "Must provide a task name")
    )
    
    Invoke-Expression "schtasks.exe /run /tn ""$Name"""
    Write-Output "Triggered scheduled task '$Name'"
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
    Write-Output "Enabled scheduled task '$Name'"
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
     Write-Output "Disabled scheduled task '$Name'"
}


<#
    -AtStartup
    -WhenIdleFor 10
    -OnceOnThe "17-04-2010"
    -Every 1 -Minute
    -Every 5 -Minutes
    -Every 2 -Hours
    -Every 10 -Days -At 21:00
    -Every 2 -Weeks -On "Mon,Wed,Fri" -At 18:30
    -Every -Month -OnThe 17 -At 04:00
    -Every -Month -In "Jan,Feb,Mar" -OnThe 17 -At 23:00
    -Every -Month -OnTheLast "Wed" -At 20:00
#>
function New-ScheduledTask
{
    param
    (
        # Task info
        [string] $Name = $(throw "Must provide a task name"),
    	[string] $Path = $(throw "Must provide the path to the executable"),
        [string] $User,
        [string] $Password,
        
        # Schedule
        [switch] $AtStartup,
        [int] $WhenIdleFor,
        [DateTime] $OnceOnThe,
        [int] $Every,
        
        # Frequency
        [Alias("Minute")] [switch] $Minutes,
        [Alias("Hour")]   [switch] $Hours,
        [Alias("Day")]    [switch] $Days,
        [Alias("Week")]   [switch] $Weeks,
        [Alias("Month")]  [switch] $Months,
        
        # Modifiers
        [string] $On,           # "Mon,Tue"  (list of days)
        [string] $In,           # "Jan,Feb"  (list of months)
        [DateTime] $At,         # 21:00       (time)
        [int] $OnThe,           # 17          (date of the month)
        [string] $OnTheFirst,   # "Mon"       (day of the month)
        [string] $OnTheLast     # "Mon"       (day of the month)
    )
    
    $basicParams = "/create /tn ""$Name"" /tr ""$Path"" /ru $User /rp $Password"
    $scheduleParams = ""
    $additionalParams = ""
    
    if ($AtStartup)
    {
        $scheduleParams = "onstart"
    }
    elseif ($OnceOnThe)
    {
        $date = $OnceOnThe.ToString("MM/dd/yyyy")
        $time = $At.ToString("HH:mm")
        $scheduleParams = "once /sd $date /st $time"
    }
    elseif ($WhenIdleFor)
    {
        $scheduleParams = "onidle /i $WhenIdleFor"
    }
    elseif ($Every)
    {      
        if ($Minutes)
        {
            $scheduleParams = "minute /mo $Every"
        }
        elseif ($Hours)
        {
            $scheduleParams = "hourly /mo $Every"
        }
        elseif ($Days)
        {
            $scheduleParams = "daily /mo $Every /st " + $At.ToString("HH:mm")
        }
        elseif ($Weeks)
        {
            $scheduleParams = "weekly /mo $Every /st " + $At.ToString("HH:mm")
            if ($On)
            {
                $scheduleParams += " /d '$On'"
            }
        }
        elseif ($Months)
        {
            if ($OnThe)
            {
                $scheduleParams = "monthly /mo $Every /d $OnThe /st " + $At.ToString("HH:mm")
            }
            elseif ($OnTheFirst)
            {
                $scheduleParams = "monthly /mo first /d $OnTheFirst /st " + $At.ToString("HH:mm")
            }
            elseif ($OnTheLast)
            {
                $scheduleParams = "monthly /mo last /d $OnTheLast /st " + $At.ToString("HH:mm")
            }
            
            if ($On)
            {
                $scheduleParams += " /d '$On'"
            }
            
            if ($In)
            {
                $scheduleParams += " /m '$In'"
            }
        }
    }
    
    $command = "schtasks.exe $basicParams /sc $scheduleParams /f"
    #$command
    Invoke-Expression $command
    Write-Output "Created scheduled task '$Name'"
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
        [string] $Name = $(throw "Must provide a task name")
    )
    
    Invoke-Expression "schtasks.exe /delete /tn ""$Name"" /f"
    Write-Output "Deleted scheduled task '$Name'"
}


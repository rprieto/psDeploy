<# 
.Synopsis 
Returns the total amount of RAM available on the system, in MB.
#> 
function Get-TotalRam
{ 
    $system = Get-WmiObject Win32_ComputerSystem
    return [int] ($system.TotalPhysicalMemory /1MB)
}

<# 
.Synopsis 
Returns the total disk size in MB.
#> 
function Get-DiskSize
{
    param
    (
        [char] $Letter = $(throw 'Driver letter is required')
    )
    
    $disk = Get-WmiObject Win32_LogicalDisk -ComputerName 'localhost' -Filter "DeviceID = '$($Letter):'"
    
    if ($disk -ne $null)
    {
        return [int] ($disk.Size / 1MB)
    }
    else
    {
        Write-Error "Could not find or access drive $Letter"
    }
}

<# 
.Synopsis 
Returns the available disk space in MB.
#> 
function Get-DiskFreeSpace
{
    param
    (
        [char] $Letter = $(throw 'Driver letter is required')
    )
    
    $disk = Get-WmiObject Win32_LogicalDisk -ComputerName 'localhost' -Filter "DeviceID = '$($Letter):'"
    
    if ($disk -ne $null)
    {
        return [int] ($disk.FreeSpace / 1MB)
    }
    else
    {
        Write-Error "Could not find or access drive $Letter"
    }
}


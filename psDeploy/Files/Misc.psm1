<# 
.Synopsis 
Syncronizes Powershell's current directory (pwd, get-location, ...) 
with the usual current directory, which most command-line utilities will use 
#> 
function Set-CurrentDirectory 
{ 
    $currentPowershellFolder = Get-Location -PSProvider FileSystem 
    [Environment]::CurrentDirectory = $currentPowershellFolder.ProviderPath 
}


<# 
.Synopsis 
Deletes and re-creates a folder on disk 
#> 
function Clear-FolderContents 
{ 
    param 
    ( 
        [string] $Path = $(throw 'Must provide path to the folder to clear') 
    ) 
   
    Remove-Item $Path -Force -Recurse -ErrorAction SilentlyContinue 
    New-item $Path -Type Directory | Out-Null 
}


<# 
.Synopsis 
Creates a backup of the source directory if it exists. 
The backup is created as a timestamped subfolder in the specified destination folder. 
#> 
function New-Backup
{ 
    param 
    ( 
        [string] $Source = $(throw 'Source is required'), 
        [string] $Destination = $(throw 'Destination is required') 
    ) 
    
    if (Test-Path $Source) 
    { 
        if (-not (Test-Path $Destination)) 
        { 
            mkdir $Destination 
        } 
        
        $date = [DateTime]::Now.ToString("yyyyMMdd_HHmmss") 
        $backupLocation = "$Destination\Backup_$date"

        Copy-Item -Path $Source -Destination $backupLocation -Recurse 
    } 
}

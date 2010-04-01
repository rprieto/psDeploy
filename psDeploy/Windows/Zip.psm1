<#
.Synopsis
Unzips an archive into a specified folder
#>
function Expand-Zip
{
    param
    (
        [string] $File = $(throw 'Must provide a service name'),
        [string] $Destination = $(throw 'Must provide the path to the new service version'),
        [switch] $CleanDestinationFirst = $false
    )
    
    if(Test-Path $File)
    {
        if ($CleanDestinationFirst)
        {
            Remove-Item $Destination -Recurse -Force
        }
        
        if (!(Test-Path -Path $Destination))
        {
            New-Item $Destination -Type Directory | Out-Null
        }

        $shell = New-Object -Com Shell.Application
        $zippedFolder = $shell.NameSpace($File)
        $destinationFolder = $shell.NameSpace($Destination)
        
        $content = $zippedFolder.Items()
        $destinationFolder.CopyHere($content)
        
        Write-Output "Unzipped '$File' into '$Destination'"
    }
    else
    {
        Write-Output "Could not find '$File' to unzip"
    }        
}
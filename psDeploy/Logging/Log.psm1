
<#
.Synopsis
Starts logging everything that happens during this deploymeny
#>
function Start-UniqueTranscript
{
    param
    (
        [string] $Name = $(throw 'Must provide the file name or prefix'),
        [string] $Path = $(throw 'Must provide the folder where to store the transcripts'),
        [switch] $AppendDate
    ) 

    if ($Path -ne $null)
    {
        Try
        {
            if (!(Test-Path $Path))
            {
                New-Item $Path -type directory | Out-Null
            }
            
            $fileName = $Name
            if ($AppendDate)
            {
                $fileName += '_' + (Get-Date -Format "yyyy-MM-dd-hh\hmm\mss\s")
            }
        
            Start-Transcript -Path "$Path\$fileName.txt"
        }
        Catch [System.Management.Automation.PSNotSupportedException]
        {
            Write-Output "Log transcripts are not available when running from the IDE"
        }
    }
}


function Stop-UniqueTranscript
{
    try
    {
        Stop-Transcript
    }
    catch [System.Management.Automation.PSNotSupportedException]
    {
    }
}


<#
.Synopsis
Adds an extry to a journal file with the details of the deployment that just finished
#>
function Get-JournalEntry
{    
    param 
    (
        [string] $Application = $(throw 'Must specify the application name'),
        [string] $Status = $(throw 'Status message is required'),
        [string] $ScriptName = $myInvocation.ScriptName
    )

    $message = " 
Application    $Application 
Script path    $ScriptName
Run by user    $env:USERDOMAIN\$env:USERNAME
Date           $(Get-Date) 
Status         $Status
"    
    
    return $message    
}


<#
.Synopsis 
Alternative to Out-File, to work around the bug that doesn't create the full folder path
#> 
function Add-ToFile
{
    param
    (
        [string] $Path = $(throw 'File path is required'),
        [string] $Value = $(throw 'Value to write is required')
    )

    if (-not (Test-Path $Path))
    {
        New-Item -Path $Path -Type File -Force | Out-Null
    }
    
    $Value | Out-File -FilePath $Path -Encoding ASCII -Append -Force
}

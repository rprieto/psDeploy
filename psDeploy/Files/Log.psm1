
<#
.Synopsis
Starts logging everything that happens during this deploymeny
#>
function Start-Log
{
    param
    (
        [string] $Path = $null,
        [string] $Prefix = "Deployment",
        [switch] $UseDate
    ) 

    if ($Path -ne $null)
    {
        Try
        {
            if (!(Test-Path $Path))
            {
                New-Item $Path -type directory
            }
            
            $fileName = $Prefix
            if ($UseDate)
            {
                $fileName += Get-Date -Format "yyyy-MM-dd-hh\hmm\mss\s"
            }
        
            Start-Transcript -Path "$Path\$fileName.log"
        }
        Catch [System.Management.Automation.PSNotSupportedException]
        {
            Write-Output "Log transcripts are not available when running from the IDE"
        }
    }
}
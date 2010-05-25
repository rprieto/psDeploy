<#
    Default log folder for all logging cmdlets
#>
$defaultLogFolder = 'C:\Logs'


<#
.Synopsis
Starts logging everything that happens during this deploymeny
#>
function Start-Log
{
    param
    (
        [string] $Name = $(throw 'Must provide the file name or prefix'),
        [string] $Path = $defaultLogFolder,
        [switch] $AppendDate
    ) 

    if ($Path -ne $null)
    {
        Try
        {
            if (!(Test-Path $Path))
            {
                New-Item $Path -type directory
            }
            
            $fileName = $Name
            if ($AppendDate)
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


<#
.Synopsis 
Writes a success message to the console and global log file 
#> 
function Write-DeploymentSuccess 
{    
    param 
    ( 
        [string] $Application = $(throw 'Must specify the application name'), 
        [string] $LogFile = "$defaultLogFolder\Deployments.txt" 
    )

        $message = " 
    -------------------------------------------- 
    Application    $Application 
    Script path    $($myInvocation.ScriptName) 
    Run by user    $env:USERDOMAIN\$env:USERNAME 
    Date           $(Get-Date) 
    Status         Deployment successful 
    --------------------------------------------"    
    
    Write-Host $message 
    Add-ToFile -Path $LogFile -Value $message 
}


<# 
.Synopsis 
Writes a failure message to the console and global log file 
#> 
function Write-DeploymentFailure 
{ 
    param 
    ( 
        [string] $Application = $(throw 'Must specify the application name'), 
        [string] $LogFile = "$defaultLogFolder\Deployments.txt" 
    )

        $message = " 
    -------------------------------------------- 
    Application    $Application 
    Script path    $($myInvocation.ScriptName) 
    Run by user    $env:USERDOMAIN\$env:USERNAME 
    Date           $(Get-Date) 
    Status         Deployment failed 
    --------------------------------------------"   
      
    Write-Warning $message 
    Add-ToFile -Path $LogFile -Value $message 
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
    
    $Value | Out-File -FilePath $Path -Append -Force
}

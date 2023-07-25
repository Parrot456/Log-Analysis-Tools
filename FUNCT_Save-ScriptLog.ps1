<#
.DESCRIPTION
Creates a "logs" subfolder in the directory the script is run. A log will be generated every day the function is run in the format $logFile-$date.log

Logs are deleted after 2 months (63 days).

.EXAMPLE
Add-ScriptLog -logFile Testing

#Note that all actions will be logged until the session ends or user runs--
Stop-transcript
#>
function Save-ScriptLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$logFile
    )
    PROCESS {
        $VerbosePreference = "Continue"
        $logPath = Join-Path -Path ($PSCommandPath | Split-Path) -ChildPath "Logs"
        if (-not (Test-Path $logPath)) {
            New-Item $logPath -ItemType Directory | Out-Null
        }
        Get-ChildItem "$logPath\*.log" | Where-Object LastWriteTime -Lt (Get-Date).AddDays(-63) | Remove-Item -Confirm:$false
        $LogPathName = Join-Path $logPath -ChildPath "$logFile-$(get-date -format 'MM-dd-yyyy').log"
        Start-Transcript $LogPathName -Append
    }
}
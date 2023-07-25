<#
.DESCRIPTION
A collection of commands and options required to create a new event and log to the windows event log.
#>

#define a source
New-EventLog –LogName Application –Source “New Source”

#write message and ID to the event log
eventOptions = @{
    ProviderName = "Microsoft-Windows-PowerShell"
    EntryType = "Information" 
    Id = "45090"
}
    LogName Application –Source “My Script” –EntryType Information –EventID 1

New-WinEvent @eventOptions -Payload @("testing123", "dance the chacha")

New-WinEvent -ProviderName Microsoft-Windows-PowerShell -Id 45090 -Payload @("Workflow", "Running")

New-WinEvent -ProviderName Microsoft-Windows-NetworkProfile -Id 10000 -Payload @("DFS share script ran successfully","Share was connected so no action taken")

Write-EventLog –LogName Application –Source “My Script” –EntryType Information –EventID 1 –Message “This is a test message.”
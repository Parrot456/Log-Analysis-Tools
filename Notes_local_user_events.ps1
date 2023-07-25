<#
.DESCRIPTION
Two examples of collecting windows event logs. The first collects info from multiple network workstations. The second collects from the local machine.
#>
###EXAMPLE 1, collect local account events from a list of workstations.###
$targetList = get-content -Path 'C:\Temp\workstations.txt'
$interestingEvents = @(
    '4720' #4720: A user account was created
    '4722' #4722: A user account was enabled
    '4738' #4738: A user account was changed
    '4724' #4724: An attempt was made to reset an account's password
    '4732' #4732: A member was added to a security-enabled local group
)
#Set time range to collect events
$Date = (get-date).AddHours(-12)

#use hashtable to filter events from application log
$filteredEvents = foreach ($eventID in $interestingEvents) {
    Get-WinEvent -FilterHashtable @{ 
        LogName='System'
        StartTime=$Date
        Id="$eventID"
        ProviderName='Microsoft-Windows-Kernel-WHEA'
    } | select-object Id,Message,Level,ProviderName,LogName,ProcessId,ThreadId,MachineName,TimeCreated,UserId | format-list
}
Invoke-Command $targetList -ScriptBlock { $filteredEvents }

###EXAMPLE 2, local event log only###
$Date = (get-date).AddHours(-12)
Get-WinEvent -FilterHashtable @{ 
    Id="45090"
    StartTime=$Date
    ProviderName='Microsoft-Windows-PowerShell'
} | select-object Id,Message,Level,ProviderName,LogName,ProcessId,ThreadId,MachineName,TimeCreated,UserId | format-list

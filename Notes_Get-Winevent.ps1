#list log types
<#
logmodes
    Circular – Overwrite the oldest log entry once full.
    Retain – Keep all events until the log is full and stop logging until freed.
    AutoBackup – Automatically back up and archive event logs once full.
LogType 
    Administrative – Primarily intended for end-users and administrative users.
    Analytical – Typically, a high volume log, meant to describe program operations.
    Debug – Meant for developers needing a deep-dive into program internals.
    Operational – An event that occurs during operation and is useful to diagnose occurrences and trigger processes.
#>
Get-WinEvent -ListLog *
Get-WinEvent -ListLog * | Select-Object LogName, RecordCount, IsClassicLog, IsEnabled, LogMode, LogType | Format-Table -AutoSize

#list providers that write to a log
(Get-WinEvent -ListLog Application).ProviderNames

#events from providers with a wilcard string in their name
Get-WinEvent -ListProvider *Policy*

#lists errors with ID and description
(Get-WinEvent -ListProvider Microsoft-Windows-GroupPolicy).Events | Format-Table Id, Description

#filter by log then select individual event properties
$Events = Get-WinEvent -LogName 'Windows PowerShell'
$Events.Count
$Events | Group-Object -Property Id -NoElement | Sort-Object -Property Count -Descending
$Events | Group-Object -Property LevelDisplayName -NoElement

#work with archived events
Get-WinEvent -Path 'C:\Test\Windows PowerShell.evtx'

#use hashtable to filter events from application log
$Date = (Get-Date).AddDays(-2)
Get-WinEvent -FilterHashtable @{ 
    LogName='Application'
    StartTime=$Date
    Id='1003' 
}

# select 1 event and view all properties
<#important properties
Message
Id
Level
ProviderName
LogName
ProcessId
ThreadId
MachineName
TimeCreated
UserId
#>
$Date = (Get-Date).AddDays(-2)
$appEvent = Get-WinEvent -FilterHashtable @{ 
    LogName='System'
    StartTime=$Date
    Id='10016' 
} | Select-Object -first 1

<#ALL PROPERTIES
Message              : The machine-default permission settings do not grant Local Activation permission for the COM Server application with CLSID 
                       {C2F03A33-21F5-47FA-B4BB-156362A2F239}
                        and APPID
                       {316CDED5-E4AE-4B15-9113-7055D84DCC97}
                        to the user DESKTOP-0DEIIFH\Admin SID (S-1-5-21-3472141054-596731019-3949029117-1001) from address LocalHost (Using LRPC) running in the application     
                       container Microsoft.Windows.ShellExperienceHost_10.0.19041.1320_neutral_neutral_cw5n1h2txyewy SID
                       (S-1-15-2-155514346-2573954481-755741238-1654018636-1233331829-3075935687-2861478708). This security permission can be modified using the Component       
                       Services administrative tool.
Id                   : 10016
Version              : 0
Qualifiers           : 0
Level                : 3
    Critical (level 1)
    Error (level 2)
    Warning (level 3)
    Information (level 4)
Task                 : 0
Opcode               : 0
Keywords             : -9187343239835811840
RecordId             : 2132
ProviderName         : Microsoft-Windows-DistributedCOM
ProviderId           : 1b562e86-b7aa-4131-badc-b6f3a001407e
LogName              : System
ProcessId            : 576
ThreadId             : 11960
MachineName          : DESKTOP-0DEIIFH
UserId               : S-1-5-21-3472141054-596731019-3949029117-1001
TimeCreated          : 12/10/2021 9:58:30 AM
ActivityId           : 418c8a1f-b3f4-48da-a1ac-deea39ebb039
RelatedActivityId    : 
ContainerLog         : System
MatchedQueryIds      : {}
Bookmark             : System.Diagnostics.Eventing.Reader.EventBookmark
LevelDisplayName     : Warning
OpcodeDisplayName    : Info
TaskDisplayName      : 
KeywordsDisplayNames : {Classic}
Properties           : {System.Diagnostics.Eventing.Reader.EventProperty, System.Diagnostics.Eventing.Reader.EventProperty, System.Diagnostics.Eventing.Reader.EventProperty,    
                       System.Diagnostics.Eventing.Reader.EventProperty…}
#>

#Log providors (sources). Multiple providers may supply a single log like Application or System.
Get-WinEvent -ListProvider * | Format-Table -Autosize

#Select all providers for a specific log. Script uses In comparison operator to check the loglinks property of all providers. Then it applies a filter so only System providers are shown.
Get-WinEvent -ListProvider * | Where-Object { 
    'System' -In ($_ | Select-Object -ExpandProperty Loglinks | Select-Object -ExpandProperty Logname) 
    } | Format-Table -AutoSize

#Classic event log searching (Application and System)
#select only some properties otherwise results will be summarized by provider without details
Get-WinEvent -LogName 'Application' -MaxEvents 100 | Select-Object TimeCreated, ID, ProviderName, LevelDisplayName, Message | Format-Table -AutoSize

#Modern event log searching
Get-WinEvent -LogName 'Microsoft-Windows-WindowsUpdateClient/Operational' -MaxEvents 10 | Select-Object TimeCreated, ID, ProviderName, LevelDisplayName, Message | Format-Table -AutoSize

#search for oldest 10 with -Oldest parameter, filters instead of sorting in final step
Get-WinEvent -LogName 'Microsoft-Windows-WindowsUpdateClient/Operational' -Oldest -MaxEvents 10 | Select-Object TimeCreated, ID, ProviderName, LevelDisplayName, Message | Format-Table -AutoSize

#search a .evtx file
Get-WinEvent -Path 'C:\Articles\WindowsPowerShell.evtx' -MaxEvents 10 | Select-Object TimeCreated, ID, ProviderName, LevelDisplayName, Message | Format-Table -AutoSize

#Narrow search parameters instead of returning all and filtering. 
<#
Options to prefilter results
    -FilterHashTable
    -FilterXPath
    -FilterXML
#>
# filtering with hashtables
Get-WinEvent -FilterHashTable @{
    'LogName' = 'Application'
    'StartTime' = (Get-Date -Hour 0 -Minute 0 -Second 0)
    } | Select-Object TimeCreated, ID, ProviderName, LevelDisplayName, Message | Format-Table -AutoSize

#Filtering with XPath language. Relies on the fact that events are stored as XML files.
#To get formatting open event log GUI and go to 'filter log'. Open the XML tab at the top and copy formatting from Select line. Complicated.
Get-WinEvent -LogName 'Application' -FilterXPath "*[System[(Level=1  or Level=3)]]" | Select-Object TimeCreated, ID, ProviderName, LevelDisplayName, Message | Format-Table -AutoSize
Get-WinEvent -LogName 'Application' -FilterXPath "*[System[TimeCreated[@SystemTime >= '$(Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0 -Format "yyyy-MM-ddTHH:mm:ss.fffZ" -AsUTC)']]]" | Select-Object TimeCreated, ID, ProviderName, LevelDisplayName, Message | Format-Table -AutoSize

#Filtering with -FilterXML. Copy entire formattng from eventlog GUI > XML tab.
#Must use single quotes not double in XML body
<#WORKING FILTER METHOD
1. Save full XML text block from event log > filter > XML to a file.
2. Add the contents of the file to a variable with-- 
    $query = (get-content -path C:\Temp\query.xml) -replace '"',''''
3. Run get-winevent and include double quotes around query variable
    $last10SystemLogs = Get-WinEvent -FilterXML "$Query" -MaxEvents 10 | Select-Object TimeCreated, ID, ProviderName, LevelDisplayName, Message
    $last10SystemLogs[1].message
#>

$Query = "<QueryList>
  <Query Id='0' Path='Application'>
    <Select Path='Application'>*[System[TimeCreated[@SystemTime >= '$(Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0 -Format "yyyy-MM-ddTHH:mm:ss.fffZ" -AsUTC)']]]</Select>
  </Query>
</QueryList>"

$Query2 = "<QueryList>
    <Query Id='0' Path='Application'>
        <Select Path='Application'>*[System[(Level=1  or Level=2 or Level=3) and TimeCreated[timediff(@SystemTime) &lt;= 86400000]]]</Select>
    </Query>
</QueryList>"

Get-WinEvent -FilterXML $Query | Select-Object TimeCreated, ID, ProviderName, LevelDisplayName, Message | Format-Table -AutoSize

Get-WinEvent -FilterXML $Query2 | Select-Object TimeCreated, ID, ProviderName, LevelDisplayName, Message | ConvertTo-Csv | out-file c:\events.csv

select-object -ExpandProperty 

Get-WinEvent -FilterXml $Query2 | Select-Object -Property TimeCreated, Id, @{N = 'Detailed Message'; E = { $_.Message } } | Sort-Object -Property TimeCreated | Select-Object -ExpandProperty 'Detailed Message'


$appEvent = Get-WinEvent -FilterHashtable @{ 
    LogName='System'
} | Select-Object -first 1


$query = $query -replace '"',''''

$query="<QueryList>
<Query Id="0" Path="Microsoft-Windows-Authentication/ProtectedUser-Client">
  <Select Path="Microsoft-Windows-Authentication/ProtectedUser-Client">*</Select>
</Query>
</QueryList>"

$query = get-content -path C:\Temp\query.xml -replace '"',''''
$EventLog = (Get-WinEvent xxxxxxx-FilterXML $Query) | ConvertTo-Xml -NoTypeInformation

$query = "<QueryList>
  <Query Id='0' Path='System'>
    <Select Path='System'>*[System[(Level=1  or Level=2 or Level=3)]]</Select>
  </Query>
</QueryList>"

$query = "<QueryList>
  <Query Id='0' Path='System'>
    <Select Path='System'>*[System[(Level=1  or Level=2 or Level=3)]]</Select>
  </Query>
</QueryList>"

Get-WinEvent -FilterXML "$Query" -MaxEvents 10 | Select-Object TimeCreated, ID, ProviderName, LevelDisplayName, Message | Format-Table -AutoSize

Get-WinEvent -FilterXML "$Query" -MaxEvents 10 | Select-Object TimeCreated, ID, ProviderName, LevelDisplayName, Message | Format-Table -AutoSize
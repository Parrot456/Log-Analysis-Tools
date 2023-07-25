#https://nxlog.co/documentation/nxlog-user-guide/powershell-activity.html



Open the Group Policy MMC snapin (gpedit.msc).

Go to Computer Configuration › Administrative Templates › Windows Components › Windows PowerShell and open the Turn on PowerShell Transcription setting.

Select Enabled. Set a system-wide transcript output directory if required. Check the Include invocation headers option (this setting generates a timestamp for each command and is recommended).
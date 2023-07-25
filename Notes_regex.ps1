<#powershell uses the .NET framework to manipulate regular expressions
https://regex101.com/ for formatting help
#>
#-match

#return a boolean value if the pattern is present in a string
$greeting = "Hello world"

$greeting -match "ello"

#replace a pattern in a string with a different pattern, original string is preserved (var is not updated)
$greeting = "Hello world"

$greeting -replace "world", "planet"

#remove the date from a filenames, finds 4 digits with \d{4} and replaces with nothing
Get-ChildItem c:\temp\files | Rename-Item -NewName { $_.name -replace '\d{4}','' }

#rename files in a directory from .log to .txt
Get-ChildItem c:\temp\files | Rename-Item -NewName { $_.name -replace '\.log$','.txt' }

#case sensitive options for match and replace 
-imatch
-ireplace

#multiple matches are added to an array with a default name
$matches

#replace multiple matches 
-creplace
-ireplace

#directly replace part of a string
"Welcome to LazyAdmin".Replace('to','at')

#search for matches with a regex pattern, % is an alias for foreach-object
$str = "Cookbook"
[regex]::matches($str, "\woo\w") #returns one object for every match (oo with whatever letter is on either side) along with type info like length

#filter the above results with foreach-object and select only the values matched
([regex]::matches($str, "\woo\w") | %{$_.value})

#apply .NET classes 
[regex]::matches($str, "[a-z]ook", "IgnoreCase")

#replace italicized words with double words 
$str = [regex]::Replace($str, "<i>(\w+)</i>", '$1 $1');



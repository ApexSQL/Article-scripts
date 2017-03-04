#Author: Daniel Tikvicki
#The first part of the script is fetching events related to OFFLINE status;
Get-WinEvent -FilterHashtable @{logname=’application’;id=5084;} | 
?{$_.message -match "Setting database option OFFLINE"} -ErrorAction SilentlyContinue | 
Out-File d:\DatabaseStatusChange.txt -Append -Force
##
#The second part of the script is fetching events related to ONLINE status;
Get-WinEvent -FilterHashtable @{logname=’application’;id=5084;} | 
?{$_.message -match "Setting database option ONLINE"} -ErrorAction SilentlyContinue | 
Out-File d:\DatabaseStatusChange.txt -Append -Force
#After data fetching, all events will be parsed into one text file, and every next attempt of executing this script will be appended in the same text file;

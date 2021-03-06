Enable-PSRemoting #not necessary if it's already enabled
Set-Item WSMAN:\localhost\Client\trustedhosts -Value * #Probably better to add explicit hosts.

$cred = Get-Credential

#Change IOC lists as needed.
$files_list = Get-Content('C:\Users\DCI Student\Desktop\files.txt')
$ips_list = Get-Content('C:\Users\DCI Student\Desktop\ips.txt')
$registry_list = Get-Content('C:\Users\DCI Student\Desktop\reg.txt')

$targets = Get-Content("C:\Users\DCI Student\Desktop\hosts.txt")
 

foreach ($system in $targets){
    
    #Make sure to modify the search path based on the known location of IOC files.
    Invoke-Command -ComputerName $system -Credential $cred -ScriptBlock {Write-Host "Searching for known IOC files on host: $using:system...`n" -ForegroundColor Yellow
        foreach ($file in $Using:files_list) {Get-ChildItem -Path 'C:\Users\DCI Student\AppData\' -Recurse -Include $file -ErrorAction SilentlyContinue -Force}} >> 'C:\Users\DCI Student\Desktop\output.txt'
    
    Invoke-Command -ComputerName $system -Credential $cred -ScriptBlock {Write-Host "Searching for known remote IOC IP addresses on host: $using:system...`n" -ForegroundColor Yellow;
        foreach ($ip in $Using:ips_list) {Get-NetTCPConnection | Where-Object -Property RemoteAddress -eq $ip}} >> 'C:\Users\DCI Student\Desktop\output.txt'

    Invoke-Command -ComputerName $system -Credential $cred -ScriptBlock {Write-Host "Searching for known IOC registry keys in HKLM on host: $using:system...`n" -ForegroundColor Yellow;
        foreach ($reg in $Using:registry_list){Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run | where { $_.Name -match $reg}}} >> 'C:\Users\DCI Student\Desktop\output.txt'

    Invoke-Command -ComputerName $system -Credential $cred -ScriptBlock {Write-Host "Searching for known IOC registry keys in HKCU on host: $using:system...`n" -ForegroundColor Yellow;
        foreach ($reg in $Using:registry_list){Get-ChildItem -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run | where { $_.Name -match $reg}}} >> 'C:\Users\DCI Student\Desktop\output.txt'

    }
 
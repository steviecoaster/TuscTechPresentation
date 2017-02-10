
#Using sessions

$Session = New-PSSession -ComputerName tusc-print

Invoke-Command -Session $Session -ScriptBlock { Get-Service | Where { $_.Status -eq 'Running'} } | Out-GridView

Exit-PSSession $Session


#Using Computername

Invoke-Command -ComputerName tusc-print -ScriptBlock { Get-Service | Where { $PSItem.Status -eq 'Running'} } | Out-GridView


#Performance

#Using a session
Measure-Command -Expression { Invoke-Command -Session $Session -ScriptBlock { Get-Service | Where { $_.Status -eq 'Running'} } }

#Using a computer name
Measure-Command -Expression { Invoke-Command -ComputerName tusc-print -ScriptBlock { Get-Service | Where { $PSItem.Status -eq 'Running'} } }

#Implicit Remoting

$containsmodule = "tusc-print"
$Session = New-PSSession -ComputerName $containsmodule

Invoke-Command -Session $Session -ScriptBlock {Import-Module PrintManagement}

Import-PSSession $Session -Module PrintManagement -Prefix demo

#Use module from other machine locally

Get-demoADComputer beethoven

# MIND = BLOWN, right?

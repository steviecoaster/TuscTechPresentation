
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


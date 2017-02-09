#Remove-itemproperty to trash values, remove-itemproperty to set, will create if they don't exist
# if remote script execution is allowed, invoke-command -computername name1,name2 -filepath c:\path\here  will work
#Another important note: Don't use quotes on the key values, I'm assuming this is only true unless there are spaces, have not verified yet

<#
Function MagicPacket {

$Mac = "00:22:19:2F:C0:36" #A201-01.tusc.kent.edu
$MacByteArray = $Mac -split "[:-]" | ForEach-Object { [Byte] "0x$_"}
[Byte[]] $MagicPacket = (,0xFF * 6) + ($MacByteArray  * 16)
$UdpClient = New-Object System.Net.Sockets.UdpClient
$UdpClient.Connect(([System.Net.IPAddress]::Broadcast),7)
$UdpClient.Send($MagicPacket,$MagicPacket.Length)
$UdpClient.Close()

}
#>

Function Auto-Login {

MagicPacket

#Filter out only computers in the Lab you want. Change the SearchBase to be the OU where your computers are located
$computers = (Get-ADComputer -Filter * -Searchbase "<LDAP String" -Server <dc fqdn>)

#loop through each computer from the list and set the registry keys for autologin appropriately and then reboot the machine
ForEach ($computer in $computers){


remove-itemproperty -path "HKLM:\software\microsoft\Windows NT\currentversion\winlogon" -Name AutoAdminLogon -Value 1 
remove-itemproperty -path "HKLM:\software\microsoft\Windows NT\currentversion\winlogon" -Name DefaultUserName -Value Kent\tusclabuser_gen -Type String
remove-itemproperty -path "HKLM:\software\microsoft\Windows NT\currentversion\winlogon" -Name DefaultPassword -Value Hurr1c@n3 -Type String
remove-itemproperty -path "HKLM:\software\microsoft\Windows NT\currentversion\winlogon" -Name DefaultDomain -Value KENT -Type String


#Restart machine which *should* use new settings and auto-login
Restart-Computer

}

}

#Call the Function you just created above.
Auto-Login


#Hardcoded. 

new-itemproperty -path "HKLM:\software\microsoft\Windows NT\currentversion\winlogon" -Name AutoAdminLogon -Value 1
new-itemproperty -path "HKLM:\software\microsoft\Windows NT\currentversion\winlogon" -Name DefaultUserName -Value DOMAIN\username -Type String
new-itemproperty -path "HKLM:\software\microsoft\Windows NT\currentversion\winlogon" -Name DefaultPassword -Value SomePassword -Type String
new-itemproperty -path "HKLM:\software\microsoft\Windows NT\currentversion\winlogon" -Name DefaultDomain -Value DOMAIN -Type String



#Better way, as a function!

Function Add-Autologin{
	
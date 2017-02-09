
#Hardcoded. 

new-itemproperty -path "HKLM:\software\microsoft\Windows NT\currentversion\winlogon" -Name AutoAdminLogon -Value 1
new-itemproperty -path "HKLM:\software\microsoft\Windows NT\currentversion\winlogon" -Name DefaultUserName -Value DOMAIN\username -Type String
new-itemproperty -path "HKLM:\software\microsoft\Windows NT\currentversion\winlogon" -Name DefaultPassword -Value SomePassword -Type String
new-itemproperty -path "HKLM:\software\microsoft\Windows NT\currentversion\winlogon" -Name DefaultDomain -Value DOMAIN -Type String



#Better way, as a function!

Function Add-Autologin{
	Param(
    [cmdletBinding()]
    [parameter(Mandatory=$true,Position=0)]
    [string]$DefaultUser,
    [parameter(Mandatory=$true,Position=1)]
    [string]$Password,
    [parameter(Mandatory=$true,Posiiton=2)]
    [string]$Domain
    )

    Write-Verbose -Message "Setting AutoLogin bit to 1..."
    New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value 1
    
    Write-Verbose  -Message "Setting default user..."
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\winlogon" -Name DefaultUserName -Value $DefaultUser -Type String
    
    Write-Verbose -Message "Setting default password..."
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value $Password -Type String
    
    Write-Verbose -Message "Setting default logon domain..."
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultDomain -Value $Domain -Type String

    Write-Verbose -Message "All operations completed, exiting..."

}
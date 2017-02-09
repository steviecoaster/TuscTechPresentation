<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.3.131
	 Created on:   	1/9/2017 2:27 PM
	 Created by:   	Stephen Valdinger
	 Organization: 	Kent State University Tuscarawas
	 Filename:     	New-EventSetup.ps1
	===========================================================================
	.DESCRIPTION
	This script injects Auto-Login information into the registry of a target computer. It will also remove those registry entries if Remove is selected as the action

	.EXAMPLE
	./New-EventSetup.ps1 -Computer A201-20 -Action Add
#>
[cmdletBinding()]
param (
	
	[Parameter(Mandatory = $false, Position = 0)]
	[string]$Computer,
	[Parameter(Mandatory = $false, Position = 1)]
	[string]$Lab,
	[Parameter(Mandatory = $true,Position = 2)]
	[ValidateSet("Add","Remove")]
	[string]$Action
		
	)



function Start-ThawComputer
{
	
	
	Write-Verbose -Message "Thawing target Computer(s) to prepare for registry changes...."
	Invoke-Command -ComputerName $Computer -ScriptBlock { dfc.exe Cyb3rTr0N /THAWNEXTBOOT }
	
	Write-Verbose -Message "Waiting for target Computer(s) to come back online before continuing..."
	Start-Sleep 10
	Do
	{
		
		Out-Null
		
	}
	
	Until ((Test-Connection -ComputerName $Computer -Count 4 -Quiet) -eq 'True')
	
	Work-Type
} # End Start-ThawComputer Function

function Start-ThawLab
{
	
	
	Write-Verbose -Message "Thawing target Computer(s) to prepare for registry changes...."
	Invoke-Command -ComputerName $script:target -ScriptBlock { dfc.exe Cyb3rTr0N /THAWNEXTBOOT }
	
	Write-Verbose -Message "Waiting for target Computer(s) to come back online before continuing..."
	Start-Sleep 10
	Do
	{
		
		Out-Null
		
	}
	
	Until ((Test-Connection -ComputerName $script:target -Count 4 -Quiet) -eq 'True')
	
	Work-Type
} # End Start-ThawLab Function
function Set-Autologin
{
	If ($Lab)
	{
		
		$Computer = $script:target	
		
	}
	Write-Verbose -Message "Adding registry entries to specified computer"
	Invoke-Command -ComputerName $Computer -ScriptBlock { new-itemproperty -path "HKLM:\software\microsoft\Windows NT\currentversion\winlogon" -Name AutoAdminLogon -Value 1 }
	Invoke-Command -ComputerName $Computer -ScriptBlock { new-itemproperty -path "HKLM:\software\microsoft\Windows NT\currentversion\winlogon" -Name DefaultUserName -Value Kent\tusclabuser_gen -Type String }
	Invoke-Command -ComputerName $Computer -ScriptBlock { new-itemproperty -path "HKLM:\software\microsoft\Windows NT\currentversion\winlogon" -Name DefaultPassword -Value Hurr1c@n3 -Type String }
	Invoke-Command -ComputerName $Computer -ScriptBlock { new-itemproperty -path "HKLM:\software\microsoft\Windows NT\currentversion\winlogon" -Name DefaultDomain -Value KENT -Type String }
	
	Write-Verbose -Message "Registry Modified.....Freezing target Computer(s)"
	Invoke-Command -ComputerName $Computer -ScriptBlock { dfc.exe Cyb3rTr0N /BOOTFROZEN }
	
	
	
	
	} #End Set Function

function Remove-Autologin
	{
	
	Set-Location 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
	
	#Set appropriate registry key values.	
	Invoke-Command -ComputerName $Computer -ScriptBlock { remove-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon -ErrorAction SilentlyContinue }
	Invoke-Command -ComputerName $Computer -ScriptBlock { remove-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUserName -ErrorAction SilentlyContinue }
	Invoke-Command -ComputerName $Computer -ScriptBlock { remove-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultPassword -ErrorAction SilentlyContinue }
	Invoke-Command -ComputerName $Computer -ScriptBlock { remove-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultDomain -ErrorAction SilentlyContinue }
	
	Write-Verbose -Message "Registry Modified.....Freezing target Computer(s)"
	Invoke-Command -ComputerName $Computer -ScriptBlock { dfc.exe Cyb3rTr0N /BOOTFROZEN }
} #End Remove Function

function Post-Op
	{
	
	$post = Read-Host "Do you need to open a web browser? (y/n)"
		If ($post -eq 'n')
			{
		
			Out-Null
		
			}
	
	If ($post -eq 'y')
			{
		
			$url = Read-Host "Please enter the web address to open (Example: www.fafsa.ed.gov)"
			Invoke-Command -ComputerName $Computer -ScriptBlock { Start-Process chrome.exe $args[0] } -ArgumentList $url
			
	}
	
	
	
	
} #End Post Op Function

function Work-Type
{
	If ($Action -eq 'Add')
	{
		
		#Set-Autologin
		Write-Output "Registry changes will be made on $_"
	}
	
	If ($Action -eq 'Remove')
	{
		
		#Remove-Autologin
		Write-Output "Registry changes will be made on $_"
		
	}
	
} #End Work-Type Function


If ($Computer -notlike '' -and $Lab -eq '')
{
	
	Start-ThawComputer
	
}

If ($Lab -notlike '' -and $Computer -eq '')
	{
		$ou = (Get-ADOrganizationalUnit -Filter 'Name -like "*"' | Where { $_.Name -like $script:Lab } | Select -ExpandProperty DistinguishedName)
		
		Foreach ($o in $ou)
		{
			$o.ToString() | Out-Null
			$targets = (Get-ADComputer -Filter * -SearchBase $ou -Server tuscdc121.kent.edu | select Name)
			
			
			foreach ($t in $targets)
			{
				$script:target = $t.Name
				
				Start-ThawLab
				
			}
		}
	
	
	}




<#
.SYNOPSIS

Provides an automated Termination method for employees who have left the company

.DESCRIPTION

By passing the Employee Username and Manager's email address to the script, it will set mail sent to the termed employee to forward to a manager, and then disable the termed employee's AD account.

.PARAMETER EmployeeUsername

.PARAMETER ForwardMailTo

.PARAMETER ArchiveHomeDir

.EXAMPLE

Terminate-Employee -EmployeeUsername [string]

.EXAMPLE

Terminate-Employee -EmployeeUsername [string] -ForwardMailTo [string]

.EXAMPLE

Terminate-Employee -EmployeeUsername [string] -ForwardMailTo [string] -ArchiveHomeDir [switch]

#>



Function Terminate-Employee {

    Param(
        [cmdletBinding()]
        [Parameter(Mandatory=$true,Position=0)]
        [string]$EmployeeUsername,
        [Parameter(Mandatory=$false,Position=1)]
		[string]$ForwardMailTo,
		[Parameter(Mandatory = $false,Positon=2)]
		[switch]$ArchiveHomeDir
    )



    If($ForwardMailTo -ne $null){
        
        #Create credential from username and secured password using key file with rights to the exchange server
        #Create Secure key
        $KeyFile = "C:\temp\AES.key"
        $Key = New-Object Byte[] 32   # You can use 16, 24, or 32 for AES
        [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
        $Key | out-file $KeyFile

        #Create encrypted Password
        $PasswordFile = "C:\temp\password.txt"
        $KeyFile = "C:\temp\AES.key"
        $Key = Get-Content $KeyFile
        $Password = "P@ssw0rd1" | ConvertTo-SecureString -AsPlainText -Force
        $Password | ConvertFrom-SecureString -key $Key | Out-File $PasswordFile
        
        #Create credential object from username and password file with AES key
        $User = "KENT\svalding"
        $key = Get-Content $KeyFile
        $MyCredential = New-Object -TypeName System.Management.Automation.PSCredential `
        -ArgumentList $User, (Get-Content $PasswordFile | ConvertTo-SecureString -Key $key)
                     

        $containsmodule = #exchangeserverfqdn
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$containsmodule/PowerShell/ -Authentication Kerberos -Credential $MyCredential
        Import-PSSession $Session 

            Set-Mailbox -Identity $EmployeeUsername -ForwardingSMTPAddress "$ForwardMailTo"
                If((Get-Mailbox -Identity $EmployeeUsername).ForwardingSMTPAddress -eq "$ForwardMailTo"){

                    Write-Verbose -Message "Forwarding enabled. Mail will now be delivered to $ForwardMailTo"
                }#end if

                Else{
                
                    Write-Verbose -Message "Forwarding failed. Check Exchange Event log for details."

                }#end else
    
    }#end forward if
    
    Try{
        
        Disable-ADAccount -Identity $EmployeeUsername

        Write-Verbose -Message "User account for $EmployeeUsername has been disabled"
        }

        Catch{

            $_.Exception.Message

            }
	
	Try{
		Set-ADAccountPassword -Identity $EmployeeUsername -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "P@ssw0rd1" -Force)
	}
	
	Catch
	{
		$_.Exception.Message	
	}
	
	If ($ArchiveHomeDir)
		{
			#Compress and archive home directory
			Write-Verbose -Message "Archiving user's home directory to zip file."
			$SourceDir = "\\fileserver\home\$EmployeeUsername"
			$DestDir = "\\fileshare\archive\$EmployeeUsername.zip"
			[Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.Filesystem")
			[io.compression.zipfile]::CreateFromDirectory($SourceDir, $DestDir)
			Remove-Item $SourceDir -Recurse -Force
		
		} #end archive if
	
    Write-Verbose -Message "All tasks completed. Check event log(s) for errrors. Exiting..."
	
} #end function
    
    
 
    
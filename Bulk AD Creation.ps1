Function New-BulkADAccounts {

$password = "P@ssw0rd!" 

    Try {
    
        Import-Csv -Path .\demoaccounts.csv | `
            ForEach-Object { ` 
                New-ADUser -Name $_.Name `
                 -Path "OU=Users,DC=test,DC=local" `
                  -SamAccountName $_."samAccountName" `
                  -UserPrincipalName $_."UserPrincipalName" `
                  -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) `
                  -ChangePasswordAtLogon $true `
                  -Enabled $true


            }
        }
    
    Catch{


       Write-Output $_.Exception.Message

        Break

    }

}

New-BulkADAccounts
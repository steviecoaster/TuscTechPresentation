Function Student-Import {
[cmdletbinding()]
Param()

$rtbl = New-Object System.Data.DataTable
$username = New-Object System.Data.DataColumn Username,([string])
$result = New-Object System.Data.DataColumn Result,([string])

[void]$rtbl.Columns.Add($username)
[void]$rtbl.Columns.Add($result)

#First things first, we clear out the membership of the group as it currently is, so we can populate it with current students.
$members = Get-ADGroupMember -Identity "TUSC Students" -Recursive -Server TUSCDC121.kent.edu

Foreach($m in $members){

Remove-ADGroupMember -Identity "TUSC Students" -Members $m.SamAccountName -Confirm:$false
Write-Verbose -Message "$($m.SamAccountName) removed"

}


#This function will open up a File box to let you browse and select your CSV file. It is being filtered to only show CSV.
Function Get-Filename($initialdirectory){

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.InitialDirectory = $initialdirectory
$OpenFileDialog.Filter = "CSV ($.csv)| *.csv"
$OpenFileDialog.ShowDialog() | Out-Null
$OpenFileDialog.FileName

}


#The path after the function call will be the Initial Directory that is visible when the popup box opens.
#This happens because we supplied a variable name in our function declaration.
#The trailing text after the call to the function becomes the value for that variable.
$inputfile = Get-Filename "C:\temp\"
$list = Get-Content $inputfile


$students = New-Object System.Collections.ArrayList



#Create an array from the CSV file
Foreach($l in $list) {

[void]$students.Add($l)

}

#Add fresh student list to the group
Foreach ($s in $students){

Add-ADPrincipalGroupMembership -Identity $s -MemberOf "CN=TUSC Students,OU=TUSC Groups,OU=TUSC,DC=kent,DC=edu" -Confirm:$false
$lec = $LASTEXITCODE

If ($lec -eq '1'){

Write-Verbose -fore "yellow" -Message "$s added to TUSC Students"

$row = $rtbl.NewRow()
$row.Username = $s
$row.Result = "Success"

$rtbl.Rows.Add($row)
}

Else {

Write-Verbose -fore "red" -Message "$s encountered an error"

$row = $rtbl.NewRow()
$row.Username = $s
$row.Result = "Failed"

$rtbl.Rows.Add($row)

}
}
Write-Host "CSV Count: $($list.Count)"
Write-Host "Group Count: $($students.Count)"

$html = $rtbl | ConvertTo-Html

If ($report -eq $true){

Send-MailMessage -To svalding@kent.edu -From studentimport@kent.edu -Body $html -BodyAsHtml -SmtpServer smtp.kent.edu -Subject "Student Import Script Results"


}

}



Student-Import
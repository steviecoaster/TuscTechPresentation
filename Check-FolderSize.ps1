Function Check-FolderSize{

    Param(
    [cmdletBinding()]
    [Parameter(Mandatory=$true,Position=0)]
    [string]$ParentPath
    )


    $startFolder = "$ParentPath"

    $colItems = (Get-ChildItem $startFolder | Measure-Object -property length -sum)
    "$startFolder -- " + "{0:N2}" -f ($colItems.sum / 1MB) + " MB"

    $colItems = (Get-ChildItem $startFolder -recurse | Where-Object {$_.PSIsContainer -eq $True} | Sort-Object)
    foreach ($i in $colItems)
        {
            $subFolderItems = (Get-ChildItem $i.FullName | Measure-Object -property length -sum -ErrorAction SilentlyContinue)
            $i.FullName + " -- " + "{0:N2}" -f ($subFolderItems.sum / 1MB) + " MB"
        }

}


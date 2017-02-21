Function Some-Function{
    Param(
        [parameter(Mandatory=$true,Position=1)]
        [string]$Value
    )

    $window = New-Object -ComObject wscript.shell
    $show = $window.popup($Value)


}
function Test-Contains
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [alias ('Comparison')]
        [array]$Arr = @(),
        [Parameter(Mandatory)]
        [string]$Key,
        [Parameter(Mandatory)]
        [alias ('Value')]
        [string]$Val
    )

    return [bool]($Arr | Where-Object { $_.$key -eq $val })
    #return ($Arr | Where-Object { $_.$key -eq $val } | Measure-Object).Count -gt 0
}
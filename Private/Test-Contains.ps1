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

    return ($Arr | Where-Object { $_.$key -eq $val }).Count -gt 0
}
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

    return $null -ne ($Arr | Where-Object { $_.$key -eq $val } | Select-Object -First 1) # This is the equivalent of the JavaScript 'some()' method.
    # Plus rapide
    # foreach ($element in $Arr)
    # {
    #     if ($element.$Key -eq $Val)
    #     {
    #         return $true
    #     }
    # }
    # return $false
}
function New-State
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Min,
        [string]$Max
    )

    $state = [PSCustomObject]@{
        Min = $Min
        Max = $Max
    }
    return $state
}